import tkinter as tk
from tkinter import simpledialog, Menu, messagebox
import sympy as sp

class BlockDiagramEditor:
    def __init__(self, root):
        self.root = root
        self.root.title("Blockschaltbild Editor")

        self.canvas = tk.Canvas(root, width=800, height=600, bg='gray')
        self.canvas.pack()

        self.components = []
        self.connections = []

        self.selected_component = None
        self.dragging_component = None
        self.start_component = None

        self.create_menus()
        self.create_fixed_points()

        # Bind events
        self.canvas.bind("<Button-1>", self.on_single_click)
        self.canvas.bind("<Double-1>", self.on_double_click)
        self.canvas.bind("<B1-Motion>", self.on_canvas_drag)
        self.canvas.bind("<ButtonRelease-1>", self.on_canvas_release)

    def create_menus(self):
        self.menu = Menu(self.root, tearoff=0)
        self.menu.add_command(label="Eigenschaften ändern", command=self.change_properties)
        self.menu.add_command(label="Löschen", command=self.delete_component)
        self.menu.add_command(label="Verbindung erstellen", command=self.create_connection)

    def create_fixed_points(self):
        self.start_point = self.canvas.create_text(50, 300, text="x(k)", font=("Arial", 24), fill="black")
        self.end_point = self.canvas.create_text(750, 300, text="y(k)", font=("Arial", 24), fill="black")
        self.components.extend([self.start_point, self.end_point])

    def on_single_click(self, event):
        try:
            self.canvas.after_cancel(self.on_single_click)  # Cancel previous single click event
            self.on_canvas_click(event)
        except Exception as e:
            print(f"Error in on_single_click: {e}")

    def on_double_click(self, event):
        try:
            self.on_canvas_double_click(event)
        except Exception as e:
            print(f"Error in on_double_click: {e}")

    def on_canvas_click(self, event):
        try:
            item = self.canvas.find_closest(event.x, event.y)
            if item:
                self.selected_component = item[0]
                self.dragging_component = self.selected_component
                print(f"Selected component: {self.selected_component}")
            else:
                self.selected_component = None
                self.dragging_component = None
        except Exception as e:
            print(f"Error in on_canvas_click: {e}")

    def on_canvas_double_click(self, event):
        try:
            item = self.canvas.find_closest(event.x, event.y)
            if item:
                self.selected_component = item[0]
                self.update_menu()
                self.menu.post(event.x_root, event.y_root)
        except Exception as e:
            print(f"Error in on_canvas_double_click: {e}")

    def on_canvas_drag(self, event):
        try:
            if self.dragging_component and self.dragging_component not in [self.start_point, self.end_point]:
                self.canvas.move(self.dragging_component, event.x - self.canvas.coords(self.dragging_component)[0], event.y - self.canvas.coords(self.dragging_component)[1])
                self.update_connections()
        except Exception as e:
            print(f"Error in on_canvas_drag: {e}")

    def on_canvas_release(self, event):
        try:
            self.dragging_component = None
        except Exception as e:
            print(f"Error in on_canvas_release: {e}")

    def update_menu(self):
        self.menu.delete(0, 'end')
        component_text = self.canvas.itemcget(self.selected_component, 'text')
        if component_text.startswith("*"):
            self.menu.add_command(label="Eigenschaften ändern", command=self.change_properties)
        self.menu.add_command(label="Löschen", command=self.delete_component)
        self.menu.add_command(label="Verbindung erstellen", command=self.create_connection)

    def change_properties(self):
        try:
            if self.selected_component:
                component_text = self.canvas.itemcget(self.selected_component, 'text')
                if component_text.startswith("*"):
                    current_value = component_text[1:] if len(component_text) > 1 else ""
                    new_value = simpledialog.askstring("Eigenschaften ändern", "Neuer Faktor:", initialvalue=current_value)
                    if new_value is not None:
                        self.canvas.itemconfig(self.selected_component, text=f"*{new_value}")
        except Exception as e:
            print(f"Error in change_properties: {e}")

    def delete_component(self):
        try:
            if self.selected_component and self.selected_component not in [self.start_point, self.end_point]:
                self.remove_connections(self.selected_component)
                self.canvas.delete(self.selected_component)
                self.selected_component = None
        except Exception as e:
            print(f"Error in delete_component: {e}")

    def add_component(self, component_type):
        try:
            x, y = 100, 100
            if component_type == "Addition":
                component = self.canvas.create_text(x, y, text="+", font=("Arial", 24), fill="red")
            elif component_type == "Multiplikation":
                component = self.canvas.create_text(x, y, text="*", font=("Arial", 24), fill="blue")
            elif component_type == "Verzögerung":
                component = self.canvas.create_text(x, y, text="z^-1", font=("Arial", 24), fill="green")
            self.components.append(component)
        except Exception as e:
            print(f"Error in add_component: {e}")

    def create_connection(self):
        try:
            if self.selected_component:
                if self.start_component is None:
                    self.start_component = self.selected_component
                    messagebox.showinfo("Verbindung erstellen", "Wählen Sie die Zielkomponente aus.")
                else:
                    end_component = self.selected_component
                    arrow = self.draw_arrow(self.start_component, end_component)
                    self.connections.append((self.start_component, end_component, arrow))
                    self.start_component = None
        except Exception as e:
            print(f"Error in create_connection: {e}")

    def draw_arrow(self, start_item, end_item):
        try:
            start_coords = self.canvas.coords(start_item)
            end_coords = self.canvas.coords(end_item)
            if start_coords and end_coords:
                start_x, start_y = start_coords[0], start_coords[1]
                end_x, end_y = end_coords[0], end_coords[1]
                return self.canvas.create_line(start_x, start_y, end_x, end_y, arrow=tk.LAST)
        except Exception as e:
            print(f"Error in draw_arrow: {e}")

    def update_connections(self):
        try:
            for start_item, end_item, arrow in self.connections:
                start_coords = self.canvas.coords(start_item)
                end_coords = self.canvas.coords(end_item)
                if start_coords and end_coords:
                    start_x, start_y = start_coords[0], start_coords[1]
                    end_x, end_y = end_coords[0], end_coords[1]
                    self.canvas.coords(arrow, start_x, start_y, end_x, end_y)
        except Exception as e:
            print(f"Error in update_connections: {e}")

    def remove_connections(self, component):
        try:
            to_remove = []
            for connection in self.connections:
                start_item, end_item, arrow = connection
                if start_item == component or end_item == component:
                    self.canvas.delete(arrow)
                    to_remove.append(connection)
            self.connections = [conn for conn in self.connections if conn not in to_remove]
        except Exception as e:
            print(f"Error in remove_connections: {e}")

    def calculate_transfer_function(self):
        try:
            z = sp.symbols('z')
            y_z = sp.Function('Y')(z)
            x_z = sp.Function('X')(z)
            equations = []
            lhs_terms = []
            rhs_terms = []
            for start_item, end_item, arrow in self.connections:
                start_text = self.canvas.itemcget(start_item, 'text')
                end_text = self.canvas.itemcget(end_item, 'text')

                if start_text == "x(k)":
                    input_signal = x_z
                else:
                    input_signal = sp.Function(start_text)(z)

                if end_text == "y(k)":
                    output_signal = y_z
                else:
                    output_signal = sp.Function(end_text)(z)

                if start_text == "+":
                    lhs_terms.append(output_signal - input_signal)
                elif start_text == "z^-1":
                    lhs_terms.append(output_signal - input_signal / z)
                elif start_text.startswith("*"):
                    factor = float(start_text[1:])
                    lhs_terms.append(output_signal - factor * input_signal)
                else:
                    lhs_terms.append(output_signal - input_signal)

            for connection in self.connections:
                start_item, end_item, arrow = connection
                start_text = self.canvas.itemcget(start_item, 'text')
                end_text = self.canvas.itemcget(end_item, 'text')
                if end_text == "x(k)":
                    rhs_terms.append(sp.Function(start_text)(z))
                if start_text == "y(k)":
                    lhs_terms.append(sp.Function(end_text)(z))

            lhs = sum(lhs_terms)
            rhs = sum(rhs_terms)
            differential_equation = sp.Eq(lhs, rhs)

            messagebox.showinfo("Differentialgleichung", f"Differentialgleichung: {differential_equation}")

            transfer_function = sp.simplify(y_z / x_z)
            messagebox.showinfo("Übertragungsfunktion", f"H(z) = {transfer_function}")

        except Exception as e:
            print(f"Error in calculate_transfer_function: {e}")

if __name__ == "__main__":
    root = tk.Tk()
    editor = BlockDiagramEditor(root)

    toolbar = tk.Frame(root)
    toolbar.pack(side=tk.TOP, fill=tk.X)

    btn_add = tk.Button(toolbar, text="Addition", command=lambda: editor.add_component("Addition"))
    btn_add.pack(side=tk.LEFT)
    btn_mul = tk.Button(toolbar, text="Multiplikation", command=lambda: editor.add_component("Multiplikation"))
    btn_mul.pack(side=tk.LEFT)
    btn_delay = tk.Button(toolbar, text="Verzögerung", command=lambda: editor.add_component("Verzögerung"))
    btn_delay.pack(side=tk.LEFT)

    btn_calc = tk.Button(toolbar, text="Übertragungsfunktion", command=editor.calculate_transfer_function)
    btn_calc.pack(side=tk.LEFT)

    root.mainloop()

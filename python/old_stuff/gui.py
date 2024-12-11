import threading
import tkinter as tk
from tkinter import ttk, simpledialog, filedialog
import json
import space_and_stars as stargen
from PIL import Image, ImageTk

def show_splash_screen(root):
    splash_window = tk.Toplevel(root)
    splash_window.title("StarGen Splash")
    splash_window.overrideredirect(True)

    splash_image = Image.open("StarGen_Splash.png")
    splash_image = splash_image.resize((640, 640))
    splash_photo = ImageTk.PhotoImage(splash_image)

    splash_label = tk.Label(splash_window, image=splash_photo)
    splash_label.pack()

    splash_window.update()
    width = splash_window.winfo_width()
    height = splash_window.winfo_height()
    x = (splash_window.winfo_screenwidth() // 2) - (width // 2)
    y = (splash_window.winfo_screenheight() // 2) - (height // 2)
    splash_window.geometry(f"{width}x{height}+{x}+{y}")

    splash_window.after(3000, splash_window.destroy)
    root.wait_window(splash_window)


class GUI:
    def __init__(self, master):
        self.master = master
        master.title("Star Gen")
        self.active_file = ""
        icon_path = "StarGen.png"
        self.icon = tk.PhotoImage(file=icon_path)
        master.iconphoto(True, self.icon)
        root.protocol("WM_DELETE_WINDOW", self.exit_app)

        self.main_frame = tk.Frame(master)
        self.main_frame.pack(side="left", padx=10, fill="both", expand=True)

        self.menu_bar = tk.Menu(master)
        master.config(menu=self.menu_bar)

        self.file_menu = tk.Menu(self.menu_bar, tearoff=0)
        self.file_menu.add_command(label="New", command=self.create_new_space, accelerator="Ctrl+N")
        self.file_menu.add_command(label="Open", command=self.open_json_file, accelerator="Ctrl+O")
        self.file_menu.add_command(label="Save")
        self.file_menu.add_command(label="Close", command=self.close_active_file)
        self.file_menu.add_command(label="Exit", command=self.exit_app)

        '''
        self.edit_menu = tk.Menu(self.menu_bar, tearoff=0)
        self.edit_menu.add_command(label="Edit")
        self.edit_menu.add_command(label="Undo")
        self.edit_menu.add_command(label="Redo")
        self.edit_menu.add_command(label="Delete")
        self.edit_menu.add_command(label="Refactor")

        self.create_menu = tk.Menu(self.menu_bar, tearoff=0)
        self.create_menu.add_command(label="System")
        self.create_menu.add_command(label="Star")
        self.create_menu.add_command(label="Planet")

        self.help_menu = tk.Menu(self.menu_bar, tearoff=0)
        self.help_menu.add_command(label="Help")
        self.help_menu.add_command(label="About")
        '''

        self.menu_bar.add_cascade(label="File", menu=self.file_menu)
        '''
        self.menu_bar.add_cascade(label="Edit", menu=self.edit_menu)
        self.menu_bar.add_cascade(label="Create", menu=self.create_menu)
        self.menu_bar.add_cascade(label="Help", menu=self.create_menu)
        '''

        #To display the stars
        self.display_frame = tk.Frame(self.main_frame)
        self.display = tk.Canvas(self.display_frame, width=640, height=360)
        self.display.config(highlightbackground="black", highlightthickness=1)
        self.display.pack(fill="both", expand=True)
        self.display_frame.pack(side="left", fill="both", expand=True, padx=10)

        #key and mouse shortcuts
        '''self.display.bind("<ButtonRelease-3>", self.show_create_menu)'''
        master.bind_all("<Control-n>", lambda event: self.create_new_space())
        master.bind_all("<Control-o>", lambda event: self.open_json_file())

        self.tree_frame = tk.Frame(self.main_frame)
        self.tree = ttk.Treeview(self.tree_frame, show="tree")
        self.tree.pack(fill="both", expand=True)
        self.tree_frame.pack(side="left", fill="both", expand=True, padx=10)
        self.tree.bind("<<TreeviewSelect>>", self.display_selected_item)

    def display_json_tree(self, data):
        self.tree.delete(*self.tree.get_children())

        for sector in data:
            sector_name = sector["SECTOR"]
            sector_node = self.tree.insert("", "end", text=sector_name, tags=("sector",))
            parsecs = sector["parsecs"]
            for parsec in parsecs:

                system_data = parsec["system_data"]
                if isinstance(system_data, dict):
                    system_id = system_data.get("ID", "")
                    parsec_node = self.tree.insert(sector_node, "end", text=system_id, tags=("parsec",))
                    self.tree.item(parsec_node, values=(json.dumps(system_data),))

                    stars = system_data.get("Stars", [])
                    for star in stars:
                        star_id = star.get("ID", "")
                        star_node = self.tree.insert(parsec_node, "end", text=star_id, tags=("star",))
                        self.tree.item(star_node, values=(json.dumps(star),))
                        
                        system_contents = star.get("System Contents", [])
                        if system_contents and isinstance(system_contents, list):
                            for planet in system_contents:
                                planet_id = planet.get("ID", "")
                                planet_node = self.tree.insert(star_node, "end", text=planet_id, tags=("planet",))
                                self.tree.item(planet_node, values=(json.dumps(planet),))
                            
                            satellites = planet.get("Satellites", [])
                            if system_contents and isinstance(system_contents, list):
                                for satellite in satellites:
                                    satellite_id = satellite.get("ID", "")
                                    satellite_node = self.tree.insert(planet_node, "end", text=satellite_id, tags=("satellite",))
                                    self.tree.item(satellite_node, values=(json.dumps(satellite),))
                else:
                    parsec_node = self.tree.insert(sector_node, "end", text=system_data, tags=("parsec",))
                    self.tree.item(parsec_node, values=(json.dumps({"ID": system_data}),))

        self.tree.tag_configure("sector", background="#E0E0E0")
        self.tree.tag_configure("parsec", background="#C0FFC0")
        self.tree.tag_configure("star", background="#C0C0FF")
        self.tree.tag_configure("planet", background="#FFC0C0")
        self.tree.tag_configure("satellite", background="#FFE0C0")


    def display_selected_item(self, event):
        selected_item = self.tree.selection()
        if selected_item:
            item = self.tree.item(selected_item[0])
            tag = item["tags"][0]
            if tag == "sector":
                self.display_sector_info(item["text"])
            elif tag == "parsec":
                system_data = json.loads(item["values"][0])
                self.display_system_info(system_data)
            elif tag == "star":
                star_data = json.loads(item["values"][0])
                self.display_star_info(star_data)
            elif tag == "planet":
                planet_data = json.loads(item["values"][0])
                self.display_planet_info(planet_data)
            elif tag == "satellite":
                satellite_data = json.loads(item["values"][0])
                self.display_satellite_info(satellite_data)

    def display_sector_info(self, sector_name):
        self.clear_display()
        self.display.create_text(10, 10, anchor="nw", text=f"Sector: {sector_name}", font=("Arial", 12, "bold"))
        self.display.create_text(10, 30, anchor="nw", text="Available Parsecs:", font=("Arial", 10))
        y = 50
        for child in self.tree.get_children(self.tree.selection()[0]):
            parsec_text = self.tree.item(child)["text"]
            self.display.create_text(20, y, anchor="nw", text=parsec_text)
            y += 20

    def display_system_info(self, system_data):
        self.clear_display()
        if isinstance(system_data, dict):
            self.display.create_text(10, 10, anchor="nw", text=f"System ID: {system_data.get('ID', 'N/A')}", font=("Arial", 12, "bold"))
            self.display.create_text(10, 30, anchor="nw", text=f"System Age: {system_data.get('System age', 'N/A')}")
            self.display.create_text(10, 50, anchor="nw", text=f"Population: {system_data.get('Population', 'N/A')}")
            
            self.display.create_text(10, 80, anchor="nw", text="Stars in the System:", font=("Arial", 10, "bold"))
            y = 100
            for child in self.tree.get_children(self.tree.selection()[0]):
                star_text = self.tree.item(child)["text"]
                self.display.create_text(20, y, anchor="nw", text=star_text)
                y += 20
        else:
            self.display.create_text(10, 10, anchor="nw", text=f"System ID: {system_data}", font=("Arial", 12, "bold"))

    def display_star_info(self, star_data):
        self.clear_display()
        self.display.create_text(10, 10, anchor="nw", text=f"Star ID: {star_data.get('ID', 'N/A')}", font=("Arial", 12, "bold"))
        self.display.create_text(10, 30, anchor="nw", text=f"Type: {star_data.get('Type', 'N/A')}")
        self.display.create_text(10, 50, anchor="nw", text=f"Age: {star_data.get('Star Age', 'N/A')}")
        self.display.create_text(10, 70, anchor="nw", text=f"Mass: {star_data.get('Stellar mass', 'N/A')}")
        self.display.create_text(10, 90, anchor="nw", text=f"Radius: {star_data.get('Radius', 'N/A')}")
        self.display.create_text(10, 110, anchor="nw", text=f"Prime World: {star_data.get('Prime world', 'N/A')}")
        self.display.create_text(10, 130, anchor="nw", text=f"Planet Count: {star_data.get('Planet Count', 'N/A')}")

    def display_planet_info(self, planet_data):
        self.clear_display()
        self.display.create_text(10, 10, anchor="nw", text=f"Planet ID: {planet_data.get('ID', 'N/A')}", font=("Arial", 12, "bold"))
        self.display.create_text(10, 30, anchor="nw", text=f"Type: {planet_data.get('Type', 'N/A')}")
        self.display.create_text(10, 50, anchor="nw", text=f"Distance: {planet_data.get('Distance', 'N/A')}")
        self.display.create_text(10, 70, anchor="nw", text=f"Gravity: {planet_data.get('Gravity', 'N/A')}")
        self.display.create_text(10, 90, anchor="nw", text=f"Atmosphere: {planet_data.get('Atmosphere', 'N/A')}")
        self.display.create_text(10, 110, anchor="nw", text=f"Population: {planet_data.get('Population', 'N/A')}")

        self.display.create_text(10, 140, anchor="nw", text="Satellites:", font=("Arial", 10, "bold"))
        y = 160
        for child in self.tree.get_children(self.tree.selection()[0]):
            satellite_text = self.tree.item(child)["text"]
            self.display.create_text(20, y, anchor="nw", text=satellite_text)
            y += 20

    def display_satellite_info(self, satellite_data):
        self.clear_display()
        self.display.create_text(10, 10, anchor="nw", text=f"Satellite ID: {satellite_data.get('ID', 'N/A')}", font=("Arial", 12, "bold"))
        self.display.create_text(10, 30, anchor="nw", text=f"Type: {satellite_data.get('Type', 'N/A')}")
        self.display.create_text(10, 50, anchor="nw", text=f"Distance: {satellite_data.get('Distance', 'N/A')}")
        self.display.create_text(10, 70, anchor="nw", text=f"Gravity: {satellite_data.get('Gravity', 'N/A')}")
        self.display.create_text(10, 90, anchor="nw", text=f"Atmosphere: {satellite_data.get('Atmosphere', 'N/A')}")
        self.display.create_text(10, 110, anchor="nw", text=f"Population: {satellite_data.get('Population', 'N/A')}")

    def clear_display(self):
        self.display.delete("all")

    def create_new_space(self):
        sector_range = simpledialog.askinteger(
            "Create New Space", "Enter the sector range:"
        )
        if sector_range is not None:
            progress_var = tk.DoubleVar()
            progress_bar = ttk.Progressbar(
                self.main_frame, variable=progress_var, maximum=100
            )
            progress_bar.pack(fill="x", padx=10, pady=5)

            status_label = tk.Label(
                self.main_frame, text="Generating sectors..."
            )
            status_label.pack()

            def generate_space_thread():
                sectors_dict = stargen.create_space(
                    sector_range, progress_var, status_label, self.master
                )
                with open("space.json", "w") as f:
                    json.dump(sectors_dict, f, indent=4, default=str)
                self.tree.delete(*self.tree.get_children())
                self.display_json_tree(sectors_dict)
                progress_bar.destroy()
                status_label.destroy()
                filename = self.save_to_json(sectors_dict)
                self.active_file = filename

            thread = threading.Thread(target=generate_space_thread)
            thread.start()

    def save_to_json(self, data):
        filename = filedialog.asksaveasfilename(
            defaultextension=".json",
            filetypes=[("JSON files", "*.json")],
            title="Save as...",
        )

        if filename:
            with open(filename, "w") as f:
                json.dump(data, f, indent=4, default=str)
            self.active_file = filename
        return filename

    def open_json_file(self):
        filename = filedialog.askopenfilename(
            filetypes=[("JSON files", "*.json")],
            title="Open JSON file",
        )
        if filename:
            with open(filename, "r") as f:
                data = json.load(f)
            self.active_file = filename
            self.tree.delete(*self.tree.get_children())
            self.display_json_tree(data)
    
    def close_active_file(self):
        self.active_file = ""
        self.tree.delete(*self.tree.get_children())

    def show_create_menu(self, event):
        self.create_menu.tk_popup(event.x_root, event.y_root)

    def exit_app(self):
        self.master.quit()


if __name__ == "__main__":
    root = tk.Tk()
    root.withdraw()

    show_splash_screen(root)

    root.deiconify()
    root.geometry("1280x720")
    app = GUI(root)
    root.mainloop()

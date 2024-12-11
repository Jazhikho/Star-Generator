class Space_Station():
    def __init__(self, station_type = None, location = None, starting_tonnage = 0):
        self.modules = Modules()
        self.station_type = self.get_station_type(station_type)
        self.max_tonnage, self.available_tonnage = self.get_tonnage(starting_tonnage)
        self.station_class = self.get_station_class()
        self.power = self.get_power()
        self.hull = self.get_hull()
        self.get_essential_systems()
        self.get_modules()
        self.population, self.staff = self.get_staff()
        self.weapons = self.get_weapons()
        
    def get_tonnage(self, starting_tonnage):
        if isinstance(self.location, Asteroid):
            tonnage = (self.location.density * 4/3 * PI * (self.location.diameter / 2) ** 3) * random.uniform(0.65, 0.85)
        else:
            additional_tonnage = roll.math("1d6!-1") * (tonnage * 0.1)
            tonnage = starting_tonnage + additional_tonnage
        return tonnage, tonnage
    
    def get_station_class(self):
        station_class = roll.bi_seek(self.max_tonnage, star_data["STATIONS"]["Classes"])
        return station_class
    
    def get_station_type(self, station_type):
        if not station_type:
            station_type = roll.bi_seek(seed(), star_data["STATION_INDEX"][self.station_class[-8:]])
        return station_type

    def get_hull(self):
        if isinstance(self.location, Asteroid):
            hull = "Stone"
        else:
            hull_roll = seed(2)
            if self.max_tonnage >= 30000: hull_roll += 3
            if self.max_tonnage >= 1000000: hull_roll += 3
            hull, tons = roll.bi_search(hull_roll, star_data["STATIONS"]["Hulls"])
            self.available_tonnage -= self.max_tonnage * tons 
        return hull

    def get_power(self):
        power_requirements = 0.2 * self.max_tonnage
        power_source = roll.bi_seek(seed(), star_data["STATIONS"]["Power"])
        power_generation = star_data["STATIONS"]["Power Generation"][power_source]
        tonnage_requirements =  round(power_requirements / power_generation)
        power_storage = round(0.1 * tonnage_requirements)
        emergency_power = round(0.1 * tonnage_requirements)
        self.available_tonnage -= tonnage_requirements + power_storage + emergency_power
        return power_source
    
    def get_essential_systems(self):
        if 30000 <= self.max_tonnage <= 2500000:
            bridge = roll.bi_seek(self.max_tonnage, star_data["STATIONS"]["Bridge"])
            sensors = 1
            if self.max_tonnage < 1000000:
                sensors += 1
        elif self.max_tonnage < 2500000:
            bridge = 100
            sensors = 4
        else:
            bridge = sensors = 0
        self.available_tonnage -= bridge + sensors

    def get_modules(self):
        standard_modules = ['hab', 'living_area', 'cargo', 'medical', 'external_docking']
        role_facilities = star_data["STATIONS"]["Role Facilities"][self.station_type]
        class_facilities = star_data["STATIONS"]["Classes"][self.station_class]["additional_modules"]
        additional_modules = ADDITIONAL_MODULES
        for module_name in standard_modules:
            module = getattr(self.modules, module_name)
            self.modules.get_capacity_and_tonnage(module, self.max_tonnage)
            self.available_tonnage -= module.tonnage

    def get_population(self):
        def get_crew_requirements(crew):
            required_crew = 0
            for module_name in dir(self.modules):
                module = getattr(self.modules, module_name, None)
                if module:
                    requirements = getattr(module, 'requirements', 100)
                    required_crew += module.tonnage / requirements
            return required_crew

        def calculate_crew(lower_bound, upper_bound):
            return round(self.tonnage / random.randint(lower_bound, upper_bound))

        if self.max_tonnage > 30000:
            staff = {
                "Executive Staff" : roll.dice("1d3"),
                "Engineers": calculate_crew(32, 38),
                "Maintenance": calculate_crew(1000, 2000),
                "Medics": calculate_crew(100, 140)
            }

            full_staff = sum(staff.values())
            staff["Crew"] = get_crew_requirements(full_staff)
            full_crew = sum(staff.values())
            staff['Staff Officers'] = round(full_crew / random.randint(10, 20))
            self.population += full_crew + staff['officers']
        
        return staff

class Modules():
    def __init__(self):
        module_names = [
            'hab', 'living_area', 'medical', 'cargo', 'external_docking', 
            'refuel_station', 'repair_bay', "construction_yard", "hanger", 
            "drone_bay", "shipbreaking", "library", "gaming_space", 
            "extended_sensors", "research_facility", "ore_refinery", 
            "manufacturing", "extended_communications", "weapon_systems", 
            "bridge", "civil_center", "residential_zone", "commercial_zone"
            ]
        self.modules = {name: Module_Data(name) for name in module_names}

    def get_std_attributes(self, module_name, tonnage):

        def get_capacity(module, tonnage):
            capacity = tonnage * module["capacity_variable"]
            return capacity
        
        def get_tonnage(capacity, module, tonnage):
            tonnage = capacity * module_var["tonnage_variable"]
            return tonnage

        module = self.modules.get(module_name)
        module_var = star_data["STATIONS"]["Module Data"][module_name]
        module.installed = True
        module.capacity = get_capacity(module_var, tonnage)
        module.tonnage = get_tonnage(module.capacity, module_var, tonnage)


class Module_Data():
    def __init__(self, name):
        self.name = name
        self.installed = False
        self.tonnage = 0
        self.capacity = 0
        self.crew = 0
        self.level = None
        self.description = None
        
                # "Administration": calculate_crew(800, 1050),
                # "Civil_bureaucracy": calculate_crew(40, 70)

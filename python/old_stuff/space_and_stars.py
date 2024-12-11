from __future__ import annotations
from typing import Optional, List, cast
from astro_methods import *
import json
import roll
import random
import numpy as np
import time

"""
The astro_methods library holds all the magic numbers and general 
methods that are used in this program, tucked away for readability. The
JSON below holds all the dictionaries needed in this file.
"""

with open("star_data.json", "r") as file:
    star_data = json.load(file)
"""
Go to the bottom of the program for the system, parsec, and sector 
generation classes.
"""

"""
# future features
# trade routes
# biodiversity
# mapping
# 'game' features -
# situations / missions
# trade
# jump mechanics
# space oddities
# class Oddities:
# rogue planets -> world characteristics
# stellar remnants -> remnants
# deep space station -> Station Class?
# class JumpRoutes:
"""

"""
The spectral types are O, B, A, F, G, K, M, and L. Luminosities I-V 
are aligned with normal distributions for the spectral type they 
represent - most stars are main sequence (V) stars. 

From here, a bunch of math happens. Every measurement is in comparison
to our Sun, with the exception of temperature, which is in Kelvin.

The mass is determined by the ranges typically found in nature.
The actual luminosity is determined based on the luminosity class,
expressed in terms of V = C*M**E, where V is luminosity or 
temperature (the equation form is the same), C is a constant value 
relative to our Sun, M is the mass, and E is the exponent. 

The radius is calculated based off of GURPS Space's equation; this may
not be correct for non-main sequence stars.

Orbits and planets are initialized for later generation.

The final two properties are just shorthands for planetary generations.
mk will reduce epistellar orbits, and close_binary means that the 
companion star will not generate any planets (planets are orbiting the
pair rather than the individual star).
"""

def create_space(
    sector_range, progress_var, status_label, master
) -> list[Sector]:
    sectors = []
    SECTOR_RANGE = range(0, sector_range)
    total_parsecs = len(SECTOR_RANGE) ** 3 * 512
    start_time = time.time()

    for x in SECTOR_RANGE:
        for y in SECTOR_RANGE:
            for z in SECTOR_RANGE:
                sector_id = f"{x}{y}{z}"
                sectors.append(Sector(sector_id, progress_var, status_label, total_parsecs, start_time, master))
    end_time = time.time()
    elapsed_time = end_time - start_time
    status_label.config(
        text=f"Generation completed in {elapsed_time:.2f} seconds"
    )

    return [sector.to_dict() for sector in sectors]


def get_planet_class(object_type, zone, luminosity, mod=0):
    if luminosity == "III":
        planet_class = star_data["III_CLASSES"][object_type]
    else:
        planet_class_roll = roll.math(f"d36+{mod}")
        planet_classes = star_data["WORLD_CLASSES"][object_type][zone]
        planet_class = roll.bi_seek(planet_class_roll, planet_classes)
    return planet_class


class Sector:
    def __init__(
        self,
        coordinates,
        progress_var,
        status_label,
        total_parsecs,
        start_time,
        master,
    ) -> None:
        self.id = f"Sector {coordinates}"
        self.master = master
        self.parsecs = self.generate_space(
            0,
            8,
            coordinates,
            progress_var,
            status_label,
            total_parsecs,
            start_time,
        )

    def generate_space(
        self,
        a,
        b,
        coordinates,
        progress_var,
        status_label,
        total_parsecs,
        start_time,
    ) -> list[object]:
        parsecs = []
        RANGE = range(a, b)
        total_range = len(RANGE) ** 3
        for index, x in enumerate(RANGE):
            for y in RANGE:
                for z in RANGE:
                    id = f"{coordinates}-{x}{y}{z}"
                    parsec = Parsec(id)
                    parsecs.append(parsec)

                    current_parsec = (
                        index * len(RANGE) ** 2 + y * len(RANGE) + z + 1
                    )
                    progress = (
                        (
                            current_parsec
                            + (total_range * int(self.id.split()[-1]))
                        )
                        / total_parsecs
                    ) * 100
                    progress_var.set(progress)

                    elapsed_time = time.time() - start_time
                    remaining_time = (elapsed_time / current_parsec) * (
                        total_parsecs - current_parsec
                    )
                    status_label.config(
                        text=f"Generating parsec {current_parsec} of {total_range} in sector {self.id.split()[-1]} \nEstimated time remaining: {remaining_time:.2f} seconds"
                    )
                    self.master.update_idletasks()
                    self.master.update()
        return parsecs

    def to_dict(self):
        parsecs = [
            parsec.to_dict()
            for parsec in self.parsecs
            if parsec.to_dict() is not None
        ]
        star_dict = {"SECTOR": self.id, "parsecs": parsecs}
        return star_dict


class Parsec:
    def __init__(self, parsec_id) -> None:
        self.id = parsec_id
        self.system_data = []
        self.star_system = self.check_and_gen_star_system()

    def check_and_gen_star_system(self):
        if roll.d100() <= 15:
            system = StarSystem(self.id)
            self.system_data = system.to_dict()
            return system
        elif roll.d100() == 1:
            anomaly = roll.bi_seek(seed(1), star_data["ANOMALIES"])
            self.system_data = anomaly
        else:
            return None

    def to_dict(self) -> Optional[dict]:
        if self.system_data:
            star_dict = {"system_data": self.system_data}
            return star_dict
        else:
            star_dict = {"parsec_id": self.id}
            return None


class StarSystem:
    def __init__(self, parsec) -> None:
        self.id = parsec
        self.population = self.age = 0
        self.stars = self.star_generator()

    def to_dict(self):
        if self.age > 1:
            age = f"{round(self.age, 2)} billion years"
        elif self.age > 0.001:
            age = f"{round(self.age * 100, 2)} million years"
        elif self.age > 0.000001:
            age = f"{round(self.age * 100000, 2)} thousand years"
        else:
            age = "Less than 1 thousand years"
        star_dict = {
            "ID": self.id,
            "System age": age,
            "Population": self.population,
            "Stars": [star.to_dict() for star in self.stars],
        }
        return star_dict

    def get_arrangement(self, system_stars) -> tuple[list, list]:
        num_stars = len(system_stars)
        if num_stars > 2:
            lower, upper = star_data["SYSTEM_ARRANGEMENT"][str(num_stars)]
            secondary_count = random.randint(lower, upper)
        else:
            secondary_count = 0
        secondaries = system_stars[:secondary_count]
        companions = system_stars[secondary_count:]
        return secondaries, companions

    def generate_companions(self, star: Primary | Secondary, companions):
        while len(companions) > 0:
            companion_star = Companion(self, companions.pop(0), star.mass_var)
            companion_star._id = (
                f"{companion_star._id}, companion of {star._id}"
            )
            star.nearby_orbits.append(companion_star.orbit)
            companion_star.nearby_orbits.append(companion_star.orbit)
            if companion_star._distance > 2:
                companion_star.generate_orbital_objects()
                self.population += companion_star.population
            else:
                star.total_mass += companion_star._stellar_mass
            companion_star.period = get_period(
                companion_star.orbit,
                companion_star._stellar_mass + star._stellar_mass,
            )
            star.companions.append(companion_star)
            self.stars.append(companion_star)

    def generate_secondary_stars(
        self, primary_star: Primary, secondaries, companions
    ):
        while len(secondaries) > 0:
            secondary_star = Secondary(
                self, secondaries.pop(), primary_star.mass_var
            )
            companion_number = min(random.randint(1, 2), len(companions))

            if companion_number > 0:
                self.generate_companions(
                    secondary_star, companions[:companion_number]
                )
                companions = companions[companion_number:]
            secondary_star.generate_orbital_objects()
            self.population += secondary_star.population
            secondary_star.period = get_period(
                secondary_star.orbit,
                secondary_star.total_mass + primary_star._stellar_mass,
            )
            self.stars.insert(0, secondary_star)

    def star_generator(self) -> list:
        self.stars = []
        system_stars = roll.bi_split(roll.dice("d10000"), star_data["STARS"])

        primary_star = Primary(self, system_stars.pop(0))
        self.age = primary_star._age

        if primary_star.luminosity == "VII" or primary_star._stellar_mass < 0.2:
            del system_stars[:]
        else:
            secondaries, companions = self.get_arrangement(system_stars)

            self.generate_secondary_stars(
                primary_star, secondaries, companions
            )
            self.generate_companions(primary_star, companions)
        primary_star.generate_orbital_objects()
        self.population += primary_star.population
        self.stars.insert(0, primary_star)

        return self.stars


class Star:
    def __init__(self, system: StarSystem, letter, mass_cap=0) -> None:
        self._system = system
        self._stellar_mass, self.mass_var = self._get_mass(mass_cap)
        self.total_mass = self._stellar_mass
        self._age = self.get_age()
        self.population = 0
        (
            self.spectral_type,
            self.luminosity_class,
            self.luminosity,
            self.temperature,
        ) = self.get_star_data(self.mass_var)
        self.flare = "e" if self.spectral_type == "M" and seed() >= 12 else ""
        self._id = f"{system.id}{letter}"
        self._radius = self.get_radius()
        self.nearby_orbits = self.planets = []
        self.prime_world = None


    def to_dict(self) -> dict:
        system_contents = []
        for item in self.planets:
            if isinstance(item, Planet | Asteroid_Belt):
                system_contents.append(item.to_dict())
        if self._age > 1:
            age = f"{round(self._age, 2)} billion years"
        elif self._age > 0.001:
            age = f"{round(self._age * 100, 2)} million years"
        elif self._age > 0.000001:
            age = f"{round(self._age * 100000, 2)} thousand years"
        else:
            age = "Less than 1 thousand years"
        star_dict = {
            "ID": self._id,
            "Type": f"{self.spectral_type}{self.luminosity_class}{self.flare}",
            "Star Age": age,
            "Stellar mass": f"{round(self._stellar_mass, 2)} stellar masses",
            "Radius": f"{round(self._radius, 2)} stellar radii",
            "Prime world": self.prime_world,
            "Planet Count": len(system_contents),
            "System Contents": system_contents if system_contents else None,
        }
        return star_dict

    def get_radius(self):
        if self.spectral_type in ["L", "T", "Y"]:
            radius = star_data["BROWN_DWARF"]["PARAMETERS"][str(self.mass_var)]["Radius"]
            multi = float(roll.bi_seek(int(self._age), star_data["BROWN_DWARF"]["MULTIPLIERS"]["RADIUS"]))
            radius *= multi
            return variability(radius)
        elif self.luminosity_class == "V":
            if self._stellar_mass < 1:
                radius = self._stellar_mass ** 0.8
            else:
                radius = self._stellar_mass ** 0.5
        elif self.luminosity_class == "VII":
            radius = VII_RADIUS * (1 / self._stellar_mass) ** (1 / 3)
        elif self.luminosity_class == "IV":
            radius = (self._stellar_mass ** 0.8) * variability(2)
        else: 
            radius = (self._stellar_mass ** 0.8) * variability(10, 0.1)
        return radius

    def _get_mass(self, mass_cap) -> tuple[float, float]:
        mass_roll = seed()
        if mass_roll == 3 and seed() > 10:
            mass = float(roll.bi_seek(seed(), star_data["BROWN_DWARF"]["MASS"]))
        else:
            mass = float(
                roll.bi_seek(
                    mass_roll, star_data["STELLAR MASS"][str(min(seed(), 14))]
                )
            )
        if 0 < mass_cap < mass:
            mass = max(0, mass_cap - 0.05 * (seed(1) - 1))
            if mass < 1: 
                mass = float(roll.bi_seek(seed(), star_data["BROWN_DWARF"]["MASS"]))
        return variability(mass), round(mass, 2)

    def get_age(self) -> float:
        base, a, b = roll.bi_search(seed(), star_data["STELLAR_AGE"])
        return variability(base + (seed(1) - 1) * a + (seed(1) - 1) * b)

    def get_star_data(self, mass) -> tuple[str, str, float, str]:
        if mass <= 0.07:
            temperature = int(roll.bi_seek(seed(2), star_data["BROWN_DWARF"]["TEMPS"]))
            spectral_type = roll.bi_seek(temperature, star_data["BROWN_DWARF"]["CLASS"])
            luminosity_class = ""
            current_luminosity = star_data["BROWN_DWARF"]["PARAMETERS"][str(mass)]["Luminosity"]
            lum_multi = float(roll.bi_seek(int(self._age), star_data["BROWN_DWARF"]["MULTIPLIERS"]["LUMINOSITY"]))
            current_luminosity *= lum_multi
        else:
            lmax = mspan = sspan = gspan = None
            current_luminosity = 0.0
            mass = str(mass)
            spectral_type = star_data["STELLAR_EVOLUTION"][mass]["Type"]
            temperature = star_data["STELLAR_EVOLUTION"][mass]["Temperature"]
            lmin = star_data["STELLAR_EVOLUTION"][mass]["L-Min"]
            if "L-Max" in star_data["STELLAR_EVOLUTION"][mass]:
                lmax = star_data["STELLAR_EVOLUTION"][mass]["L-Max"]
                mspan = star_data["STELLAR_EVOLUTION"][mass]["M-Span"]
                if "S-Span" in star_data["STELLAR_EVOLUTION"][mass]:
                    sspan = star_data["STELLAR_EVOLUTION"][mass]["S-Span"] + mspan
                    gspan = star_data["STELLAR_EVOLUTION"][mass]["G-Span"] + sspan
            if (mspan == None) or (mspan and (self._age <= mspan)):
                luminosity_class = "V"
                current_luminosity = lmin
                if lmax != None:
                    current_luminosity += (self._age / mspan) * (lmax - lmin)
            elif sspan and self._age <= sspan:
                luminosity_class = "IV"
                current_luminosity = lmax
                temperature = temperature - ((self._age - mspan) / sspan) * (
                    temperature - SUBGIANT_TEMP_MOD
                )
            elif gspan and self._age <= gspan:
                luminosity_class = "III"
                current_luminosity == lmax * 25
                temperature = 200 * (seed(2) - 2) + 3000
            else:
                luminosity_class = "VII"
                self._stellar_mass = 0.05 * (seed(2) - 2) + 0.9
                current_luminosity = 0.001
                temperature = random.uniform(4200, temperature * seed(1))
        return (
            spectral_type,
            luminosity_class,
            variability(current_luminosity, 0.1),
            variability(temperature, 0.1),
        )

    def generate_orbital_objects(self) -> None:
        def adjust_orbits(inner, outer):
            zone = sorted(self.nearby_orbits)
            f_inner = zone[0] / ZONE_FACTOR
            f_outer = zone[0] * ZONE_FACTOR
            inner_limit = outer_limit = 0
            if inner < f_inner and outer < f_outer:
                outer_limit = f_inner
            elif f_inner < inner_limit and outer_limit < f_outer:
                outer_limit = inner_limit
            elif f_inner < inner_limit and f_outer < outer_limit:
                inner_limit = f_outer
            else:
                inner_limit = inner
                outer_limit = outer
            return inner_limit, outer_limit

        def get_inner_outer():
            lmin = star_data["STELLAR_EVOLUTION"][str(self.mass_var)]["L-Min"]
            if self.luminosity_class in ["VII"]:
                inner_limit = (INNER_LIMIT**2) * (self.luminosity**0.5)
                outer_limit = (OUTER_LIMIT**2) * (self.luminosity**0.5)
            else:
                inner_limit = INNER_LIMIT * self._stellar_mass  # AU
                outer_limit = OUTER_LIMIT * self._stellar_mass  # AU
            snow_line = SNOW_LINE * (lmin**0.5)  # AU

            inner_limit = variability(inner_limit)
            outer_limit = variability(outer_limit)
            snow_line = variability(snow_line)
            if self.nearby_orbits != []:
                inner_limit, outer_limit = adjust_orbits(
                    inner_limit, outer_limit
                )
            return inner_limit, outer_limit, snow_line

        def get_planet_orbits(inner_limit, outer_limit) -> list[float]:
            orbits = []

            def get_next_orbit(prev_orbit) -> float:
                spacing = float(
                    roll.bi_seek(seed(), star_data["ORBITAL_SPACING"])
                )
                return round(prev_orbit * spacing, 2)

            first_position = inner_limit / seed(1)
            orbital_position = variability(first_position + inner_limit)
            while orbital_position < outer_limit:
                if orbital_position <= 0:
                    break
                orbits.append(orbital_position)
                orbital_position = get_next_orbit(orbital_position)
            return orbits

        def get_object_type(
            orbit, current_prime: Space_Object | None, snow_line
        ) -> Optional[Space_Object]:
            prime = current_prime
            if self.luminosity_class == "VII":
                mod = 25
                zone = "outer"
            else:
                mod = 0
                zone = "inner"
                if orbit > snow_line:
                    mod = seed(2)
                    zone = "outer"
            o_roll = seed() + mod
            object_type = roll.bi_seek(o_roll, star_data["ORBIT_TYPES"])

            if object_type in ["Empty", "Space"]:
                return prime
            elif object_type in ["Asteroid Belt", "Debris Field"]:
                orbital_object = Asteroid_Belt(orbit)
            else:
                planet_class = get_planet_class(
                    object_type, zone, self.luminosity_class
                )
                orbital_object = Planet(planet_class, orbit, zone, self)
            if prime == None:
                prime = orbital_object
            elif orbital_object.homeworld == True:
                self.population += orbital_object.population
                if prime.homeworld == False:
                    prime = orbital_object
            elif orbital_object.desirability > prime.desirability:
                prime = orbital_object
            self.planets.append(orbital_object)
            return prime

        def outpost_check(world: Space_Object, distance):
            outpost_roll = seed(1) + distance
            g_mod = 2 if goldilocks_inner < world._orbit < goldilocks_outer else 0
            if world.desirability + g_mod >= outpost_roll and not world.homeworld:
                world.outpost = True
                world.generate_population()
                self.population += world.population
        
        if self.mass_var < 0.1:
            return

        goldilocks_inner = (self.luminosity/1.1) ** 0.5
        goldilocks_outer = (self.luminosity/0.53) ** 0.5
        prime = None
        inner, outer, snow = get_inner_outer()
        if inner == outer:
            return
        orbits = []
        orbits = get_planet_orbits(inner, outer)
        for orbit in orbits:
            prime = get_object_type(orbit, prime, snow)
        if isinstance(prime, Space_Object):
            if prime.population == 0:
                roll_result = max(seed(2)-2, 0)
                g_mod = 2 if goldilocks_inner < prime._orbit < goldilocks_outer else 0
                if prime.desirability + g_mod > roll_result:
                    prime.generate_population()
                    self.population += prime.population
            for world in self.planets:
                if isinstance(world, Space_Object) and (world.population == 0):
                    distance = abs(prime._orbit - world._orbit) / 2
                    outpost_check(world, distance)
                if isinstance(world, Planet) and (len(world.satellites) > 0):
                    for satellite in world.satellites:
                        if isinstance(satellite, Planet):
                            distance = abs(prime._orbit - world._orbit) / 2
                            outpost_check(satellite, distance)
        if prime:
            self.prime_world = prime._id


class Primary(Star):
    def __init__(self, system, letter) -> None:
        super().__init__(system, letter)
        self.companions = []


class Secondary(Star):
    def __init__(self, system: StarSystem, letter, mass_cap) -> None:
        super().__init__(system, letter, mass_cap)
        self._id = f"{system.id}{letter} (Secondary)"
        self.companions = []
        self._distance = float(
            roll.bi_seek(seed(), star_data["SECONDARY_ORBIT"])
        )
        self.orbit = get_orbit(self._radius, self._distance)
        self.period = 0


class Companion(Star):
    def __init__(self, system, letter, mass_cap) -> None:
        super().__init__(system, letter, mass_cap)
        self._distance = float(
            roll.bi_seek(seed(), star_data["COMPANION_ORBIT"])
        )
        self.orbit = get_orbit(self._radius, self._distance)
        self.period = 0


class Massive_Star(Star):
    def __init__(self, system) -> None:
        super().__init__(system, "A")
        self.companions = []
    
    def _get_mass(mass_cap):
        mass = 3 + random.expovariate(0.2)
        mass_cap = int(roll.bi_seek(round(mass, 1), star_data["MASS_MAP"]))
        return mass, mass_cap
    
    def get_star_data(self):
        type_data = star_data["MASSIVE_STARS"][self.mass_var]
        mass_adjust = self._stellar_mass/self.mass_var
        spectral_type = type_data["Type"]
        luminosity = variability(type_data["Luminosity"] * mass_adjust)
        temperature = variability(type_data["Temperature"] * mass_adjust)
        return spectral_type, "V", luminosity, temperature

    def get_age(self):
        stable_span = star_data["MASSIVE_STARS"][self.mass_var]["Stable Span"]
        age = seed() * stable_span / 18
        return age

    def get_radius(self):
        m = self._stellar_mass
        radius = OB_A * m ** 2 + OB_B * m + OB_C
        return radius


class Neutron_Star(Star):
    def __init__(self, system) -> None:
        super().__init__(system, "A")

    def _get_mass(mass_cap):
        mass_cap = (seed(2) + 9) * 0.1
        mass = variability(mass_cap)
        return mass, mass_cap
    
    def get_star_data(self):
        return "Neutron Star", "", 0.001, variability(1e6)
    
    def get_age(self):
        return (seed(2) - 2) * random.uniform(0.1, 1.0)

    def get_radius(self):
        radius = (self.mass_var + 9.5)
        return variability(radius)


class Space_Object:
    def __init__(self) -> None:
        self._id = None
        self.total_mass = None
        self._orbit = None
        self.blackbody = None
        self.desirability = None
        self.homeworld = False
        self.population = self.government = self.factions = 0
        self.tech_level = self.economics = 0
        self.starport = None
        self.outpost = False

    def generate_population(self) -> None:
        pop = World_Population(self, self.outpost)
        self.tech_level = pop.tech_level
        self.population = pop.population
        self.factions = pop.factions
        self.government = pop.government
        self.economics = pop.economics
        self.starport = pop.starport
        self.outpost_type = pop.outpost_type


class Planet(Space_Object):
    def __init__(
        self, planet_type, orbit, zone, parent: Star | Space_Object | StarSystem, sat=False
    ) -> None:
        super().__init__()
        self._parent, self._orbit, self._zone = (parent, orbit, zone)
        if isinstance(parent, Star | Planet):
            self._age = parent._age
            self.spectral_type = parent.spectral_type
            self.luminosity = parent.luminosity
        else:
            self._age = seed(2) * seed(2) / 10
            self.spectral = self.lum = ""
        self._type_data = self._get_planet_type(planet_type)
        self.orbital_period = self.satellite_tidal_forces = 0
        self.orbital_cycle = self.ring_system = None
        self.eccentricity = float(roll.bi_seek(seed(), star_data["ECCENTRICITY"]))
        self.satellites = []
        self.is_satellite = sat
        self._id = self._get_id(sat, planet_type)
        self.blackbody = self._get_blackbody()
        self._size, _adjusted_size, self._size_category = self._get_size()
        self.atmo, self._atmo_mass, self._atmo_composition = self._get_atmo(
            _adjusted_size
        )
        self._hydro, self._hydro_coverage = self._get_hydro(_adjusted_size)
        self._biosphere, self._chemistry = self._get_bio(_adjusted_size)
        self._temp, self._climate, self.absorption = self._get_climate()
        self.density = self._get_density(self._size_category)
        self.diameter = calculate_diameter(self._size)
        self.total_mass = calculate_mass(self.diameter, self.density)
        self.gravity = self.density * self.diameter / 2
        if isinstance(self._parent, Star | StarSystem):
            if isinstance(self._parent, Star): 
                parent_mass = parent.total_mass
                mass = parent_mass + (self.total_mass * TO_SUN)
                self.orbital_period = round(get_period(orbit, mass, sat), 2)
            else: parent_mass = 0
            self.rotational_period = self.get_rotational_period(
                parent_mass
            )
            if self.orbital_period * 8760 <= self.rotational_period:
                if seed() >= 12: self.rotational_period = 5840 * self.orbital_period
                else: 
                    self.rotational_period = 8760 * self.orbital_period
                    self.adjust_for_tidal_lock()
            self.local_day = self.get_local_day(
                self.orbital_period, self.rotational_period
            )
            if self._size >= 5:
                self.satellites = self.get_satellites()
        self.axial_tilt = self.get_axial_tilt()
        self.volcanic_activity, self.tectonic_activity, _resource_mod = (
            self.get_geological_activity(planet_type, sat)
        )
        self.resources = int(
            roll.bi_seek(
                (seed() + _resource_mod), star_data["WORLD_RESOURCES"]
            )
        )
        self.homeworld = True if self._biosphere >= 12 else False
        self.desirability = self.get_desirability(_adjusted_size)
        if self.homeworld == True:
            self.generate_population()

    def to_dict(self):
        def orbital_dynamics(orbit = self.orbital_period, rotation = abs(self.rotational_period), day = abs(self.local_day)):
            def get_orbit(orbit) -> str:
                if orbit == "Rogue":
                    x = random.choice(
                        ["Strongly Coreward", "Weakly Coreward,", 
                        "Strongly Rimward", "Weakly Rimward", "Stable"])
                    y = random.choice(
                        ["Strongly Spinward", "Weakly Spinward", 
                        "Strongly Trailward", "Weakly Trailward", "Stable"])
                    z = random.choice(
                        ["Strongly Zenithward", "Weakly Zenithward", 
                        "Strongly Nadirward", "Weakly Nadirward", "Stable"])
                    orbit = f""""Open trajectory, 
                        {x} movement respective to core, 
                        {y} movement respective to spin, and 
                        {z} movement respective to the ecliptic"""
                elif orbit < 1:
                    orbit = f"{round(orbit * 24, 2)} hours" 
                elif orbit > 730:
                    orbit = f"{round(orbit / 365, 2)} years"
                else: 
                    orbit = f"{round(orbit, 2)} days"
                return orbit

            def get_rotation(rotation):
                if rotation >= self.orbital_period:
                    rotation = "Tidally Locked"
                else:
                    if rotation > 48:
                        rotation = f"{round(rotation / 24, 2)} days"
                    else:
                        rotation = f"{round(rotation, 2)} hours"
                if self.rotational_period < 0: 
                    rotation = f"{rotation} (retrograde)"
                return rotation
            
            def get_day(day, rotation):
                if rotation  >= self.orbital_period and not self.is_satellite:
                    day = "Tidally locked"
                elif self.orbital_period == 0:
                    day = rotation
                elif day / 24 > 365:
                    day = f"{round(day / 24 / 365, 2)} years"
                elif day > 48:
                    day = f"{round(day / 24, 2)} days"
                else: 
                    day = f"{round(day, 2)} hours"
                return day

            return get_orbit(orbit), get_rotation(rotation), get_day(day, rotation)

        orbit, rotation, day = orbital_dynamics()
        planet_dict = {
            "ID": self._id,
            "Diameter": f"{round(self.diameter, 2)} Earth Diameters",
            "Rings" : "None" if self.ring_system == None else self.ring_system,
            "Orbital period": orbit,
            "Rotational period": rotation,
            "Axial Tilt": f"{round(self.axial_tilt, 2)} degrees",
            "Day length": day,
            "Atmospheric Composition": self._atmo_composition,
            "Atmospheric Pressure": f"{round(self._atmo_mass, 2)} Earth normal",
            "Surface Gravity": f"{round(self.gravity, 2)} G",
            "Desirability" : self.desirability,
            "(Delete from here) Density:" : self.density,
        }
        if isinstance(self._temp, int | float):
            planet_dict["Average Surface Temperature"] = f"{round(self._temp * 1.8 - 460, 2)} degrees Fahrenheit"
            planet_dict["Climate"] = self._climate
        else:
            planet_dict["Dayside Temperature"] = f"{round(self._temp[0] * 1.8 - 460, 2)} degrees Fahrenheit"
            planet_dict["Nightside Temperature"] = f"{round(self._temp[1] * 1.8 - 460, 2)} degrees Fahrenheit"
        if self._biosphere > 0:
            planet_dict["Native Biology"] = f"{self._chemistry} based {roll.bi_seek(self._biosphere, star_data["BIOSPHERE_LEVEL"])}"
        if self.homeworld:
            planet_dict["Homeworld"] = "Homeworld"
        if self.outpost:
            planet_dict["Outpost"] = self.outpost_type
        if self.population > 0:
            planet_dict.update(
                {
                    "Population": self.population,
                    "World Unity": self.factions,
                    "Government": self.government,
                    "Economics": self.economics,
                    "Tech Level": self.tech_level,
                    "Starport": self.starport,
                }
            )
        if self.satellites:
            planet_dict.update(
                {
                    "Satellite Count": len(self.satellites),
                    "Satellites": [
                        satellite.to_dict() for satellite in self.satellites
                    ],
                }
            )
        return planet_dict

    def _get_id(self, sat, planet_type) -> str:
        if sat == False:
            return f"{planet_type} planet, {round(self._orbit, 2)} AU around {self._parent._id}"
        else:
            return (
                f"{planet_type} satellite at {round(self._orbit, 2)} kms orbit"
            )

    def adjust_for_tidal_lock(self) -> None:
        atmo_class = roll.bi_seek(self.atmo, ATMO_CLASS)
        adjust_data = star_data["TIDAL_ADJUST"][atmo_class]
        day = adjust_data["Day"]
        night = adjust_data["Night"]
        if self.atmo >= 3 and hasattr(adjust_data, "Final_Atmo"):
            self.atmo = adjust_data["Final_Atmo"]
        elif self.atmo >= 5:
            self.atmo -= 2
        self._hydro_coverage = max(
            self._hydro_coverage + adjust_data["Hydro_Penalty"], 0
            )
        self._temp = [day * self._temp, night * self._temp]

    def _get_planet_type(self, planet_type) -> dict:
        return star_data["TYPE_DATA"][planet_type]

    def _get_blackbody(self) -> float:
        if isinstance(self._parent, Star):
            return (
                BLACKBODY
                * (self._parent.luminosity**0.25)
                / (self._orbit**0.5)
            )
        elif isinstance(self._parent, Space_Object):
            return self._parent.blackbody
        else: 
            return 2.7

    def _get_size(self) -> tuple[int, int, str]:
        size_category = None
        size = roll.math(self._type_data["Size"])
        adjusted_size = int(size / 1.625)
        for category, sizes in PLANET_SIZE_CATEGORY.items():
            if size in sizes:
                size_category = category
                break
        return size, adjusted_size, size_category

    def get_attr(self, attr):
        attr_roll = self._type_data[attr]
        if isinstance(attr_roll, int):
            result = attr_roll
        elif isinstance(attr_roll, str):
            result = roll.min_max(attr_roll, 0, 15)
        return result

    def adjusted_results(self, result, attr):
        if hasattr(self._type_data, f"{attr}_results"):
            adjustment = roll.bi_seek(
                result, self._type_data[f"{attr}_results"]
            )
            if isinstance(adjustment, int):
                result = adjustment
            elif isinstance(adjustment, str):
                result = roll.math(adjustment)
        return result

    @staticmethod
    def get_atmo_composition(atmo):
        taint = toxicity = ""
        if atmo in TAINTED_ATMOSPHERES:
            taint = roll.bi_seek(seed(), star_data["TAINTED_ATMO"])
            if taint in [": Low Oxygen", " High Oxygen"]:
                tox_roll = atmo
                if (seed(2) > 7 and atmo > 7 and taint == " High Oxygen"):
                    tox_roll += 9
            else:
                tox_roll = seed()
            toxicity = roll.bi_seek(tox_roll, star_data["TOXICITY LEVEL"][taint])
        atmo_composition = (
            f'{roll.bi_seek(atmo, star_data["ATMO_COMPOSITION"])}{taint}{toxicity}'
        )
        return atmo_composition

    def _get_atmo(self, size):
        star = self.spectral_type
        lum = self.luminosity

        def get_atmo_mod():
            mod = 0
            if self._type_data["Planet_class"] == "Arean":
                mod -= 2 if lum in ["III"] else 0
            if self._type_data["Planet_class"] == "Oceanic":
                mod -= 1 if lum == "IV" else 0
                mod -= 1 if star == "K" and lum == "V" else 0
                mod -= 2 if star == "M" and lum == "V" else 0
                mod -= 3 if lum == "VII" else 0
            return mod

        atmo = self.get_attr("Atmosphere")
        if self._type_data["Planet_class"] in ATMO_MOD:
            atmo += size
        atmo += get_atmo_mod()
        atmo = self.adjusted_results(atmo, "Atmosphere")

        if atmo > 12:
            atmo_mass = 10 + random.expovariate(DENSE_ATMO)
        elif atmo > 0:
            atmo_mass_min, atmo_mass_max = roll.bi_search(
                atmo, star_data["ATMO_MASS"]
            )
            atmo_mass = random.uniform(atmo_mass_min, atmo_mass_max)
        else:
            atmo_mass = 0
        atmo_composition = self.get_atmo_composition(atmo)

        return atmo, variability(atmo_mass), atmo_composition

    def _get_hydro(self, size):
        star = self.spectral_type

        def get_hydro_mod():
            mod = 0
            if self._type_data["Planet_class"] == "Rockball":
                mod += 1 if star == "L" else 0
                mod += (
                    2
                    if self._zone == "Outer"
                    else -2 if self._zone == "Epistellar" else 0
                )
            if self._type_data["Planet_class"] == "Arean":
                mod -= 4 if self.atmo == 1 else 0
            return mod

        hydro = self.get_attr("Hydrosphere")
        if self._type_data["Planet_class"] in HYDRO_MOD:
            hydro += size
        hydro += get_hydro_mod()
        hydro = self.adjusted_results(hydro, "Hydrosphere")
        hydro_coverage = hydro * 10

        return hydro, round(min(variability(hydro_coverage), 100))

    def _get_bio(self, size):
        star = self.spectral_type
        lum = self.luminosity

        def get_chem_mod():
            mod = 0
            if self._type_data["Planet_class"] in [
                "Arid",
                "Oceanic",
                "Panthalassic",
                "Tectonic",
            ]:
                mod += 2 if self._zone == "Outer" else 0
                mod += 2 if star == "K" and lum == "V" else 0
                mod += 4 if star == "M" and lum == "V" else 0
                mod += 5 if lum == "VII" else 0
            if self._type_data["Planet_class"] in ["Jovian", "Promethean"]:
                mod += (
                    2
                    if self._zone == "Outer"
                    else -2 if self._zone == "Epistellar" else 0
                )
                mod += 2 if lum == "VII" else 0
            if self._type_data["Planet_class"] in ["Arean", "Snowball"]:
                mod += 2 if lum == "VII" else 0
                mod += 2 if self._zone == "Outer" else 0
            return mod

        def bio_results(chem, bio) -> int:
            final_case = 4
            chem_mod = star_data["CHEM_MOD"][chem]
            if self._type_data["Planet_class"] == "Arean":
                if self.atmo not in [1, 10]:
                    return 0
                if self.atmo == 1 and self._age >= bio + chem_mod:
                    return 3
                elif self.atmo == 1:
                    return 0
            if self._type_data["Planet_class"] == "Snowball":
                final_case += 2
            if self._age >= chem_mod + bio:
                return 1
            elif self._age >= final_case + chem_mod:
                return 2
            else:
                return 0

        def adjust_atmo(bio, chem) -> None:
            if self._type_data["Planet_class"] == "Oceanic":
                if chem != "Water":
                    self.atmo = int(
                        roll.bi_seek(
                            roll.dice("d6"), self._type_data["Atmo2_results"]
                        )
                    )
                    self._atmo_composition = self.get_atmo_composition(
                        self.atmo
                    )
                return
            elif bio < 3 or chem != "Water":
                if (
                    self._type_data["Planet_class"]
                    in ["Tectonic", "Vesperian"]
                    and bio >= 3
                    and chem in ["Sulfur", "Chlorine"]
                ):
                    self.atmo = 11
                else:
                    self.atmo = 10
                self._atmo_composition = self.get_atmo_composition(self.atmo)

        if self._type_data["Chemistry"] == 0:
            return 0, "None"
        else:
            chem_num = self.get_attr("Chemistry")
            if self._type_data["Planet_class"] in BIO_CHEM:
                chem_num += get_chem_mod()
            chem = roll.bi_seek(chem_num, self._type_data["Chemistry_results"])

            bio = self.get_attr("Biosphere")
            if self._type_data["Planet_class"] == "Jovian":
                bio += 2 if self._zone == "Inner" else 0
            bio = bio_results(chem, bio)
            bio = self.adjusted_results(bio, "Biosphere")
            if self._type_data["Planet_class"] == "Snowball":
                bio += size
            if self._type_data["Planet_class"] in ADJ_ATMO:
                adjust_atmo(bio, chem)
            return bio, chem

    def _get_climate(self):
        b = float(self.blackbody)
        a = self._type_data["Absorption"]
        if isinstance(a, dict):
            a = float(roll.bi_seek(seed(2), a))
        a = min(variability(a), 1)
        m = float(self._atmo_mass)
        g = float(self._type_data["Greenhouse"])
        if g > 0:
            g = variability(g)
        temp = b * (a * (1 + (m * g)))
        if isinstance(self._parent, Planet):
            temp_from_planet = (
                self._parent.blackbody * (
                    (self._parent.diameter * 0.5) ** 2 / self._orbit ** 2 *(
                        1 - self._parent.absorption
                    )
                )
            ) ** 0.25
            temp_from_tidal = (
                63 / 16 * PI * (
                    self._parent.total_mass ** 3 * self.eccentricity ** 2
                ) / (
                    self._orbit ** 7 * 0.00000567
                )
            ) ** 0.25
            temp += temp_from_planet + temp_from_tidal
        climate = roll.bi_seek(temp, star_data["CLIMATE"])
        return temp, climate, a

    def _get_density(self, size):
        coretype = star_data["CORETYPE"][size][self._zone]
        density = float(
            roll.bi_seek(seed(), star_data["CORE_DENSITY"][coretype])
        )
        return variability(density)

    def get_satellites(self):
        satellites = []

        def generate_moons(moons, start, end, moon_type, mod):
            planet_positions = []
            while len(planet_positions) < moons:
                position = random.uniform(start, end)
                if all(abs(position - pos) >= 1 for pos in planet_positions):
                    planet_positions.append(position)
                else:
                    moons -= 1
            for orbit in planet_positions:
                moon_class = get_planet_class(
                    moon_type, self._zone, self.luminosity, mod
                )
                moon = Planet(moon_class, orbit, self._zone, self, True)
                mass = self.total_mass + moon.total_mass
                moon.orbital_period = get_period(orbit, mass, self.is_satellite)
                self.satellite_tidal_forces += (
                    moon.total_mass * self.diameter
                ) / orbit**3
                moon.satellite_tidal_forces = (
                    self.total_mass * moon.diameter
                ) / orbit**3
                total_tidal_force = round(
                    (moon.satellite_tidal_forces * self._age)
                    / moon.total_mass
                )
                if total_tidal_force >= 50:
                    moon.rotational_period = moon.orbital_period
                else:
                    moon.rotational_period = get_rotation(
                        moon._size_category,
                        total_tidal_force,
                        True,
                    )
                moon.local_day = self.get_local_day(
                    self.orbital_period, moon.rotational_period
                )
                self.orbital_cycle = self.get_local_day(
                    moon.orbital_period, self.rotational_period
                )
                satellites.append(moon)

        def determine_rings():
            if self._zone == "epistellar" or self._orbit <= HALF_AU:
                return
            prob_rings = max(5 + 2.5 * self._size, 0)
            prob_spec_rings = (
                max((30 / (26 - 8)) * (self._size - 8), 0)
                if self._size >= 8
                else 0
            )
            total_prob = prob_rings + prob_spec_rings
            if total_prob > 100:
                prob_rings = (prob_rings / total_prob) * 100
                prob_spec_rings = (prob_spec_rings / total_prob) * 100
            rings = np.random.choice(
                [None, "Simple", "Complex"],
                p=[
                    max(100 - prob_rings - prob_spec_rings, 0) / 100,
                    prob_rings / 100,
                    prob_spec_rings / 100,
                ],
            )
            if rings:
                orbit_1 = roll.math("(d6+4)/4") * self.diameter
                orbit_1 = variability(orbit_1)
                orbit_2 = roll.math("(d6+4)/4") * self.diameter
                orbit_2 = variability(orbit_2)
                if rings == "Simple":
                    orbit = round((orbit_1 + orbit_2) * 400, 2)
                    self.ring_system = f"{rings} ring at {orbit} km"
                elif rings == "Complex":
                    inner = round(min(orbit_1, orbit_2), 2)
                    outer = round(max(orbit_1, orbit_2), 2)
                    self.ring_system = (
                        f"{rings} rings from {inner} to {outer} km"
                    )

        def get_terrestrial_moon_count(moons):
            if self._orbit <= HALF_AU:
                return 0
            elif self._orbit <= THREE_QUARTERS_AU:
                moons -= 3
            elif self._orbit <= ONE_HALF_AU:
                moons -= 1
            if self._size <= 4:
                moons -= 2
            elif self._size <= 8:
                moons -= 1
            elif self._size >= 13:
                moons += 1
            moons = max(moons, 0)
            return moons

        def get_major_moons():
            if self._size >= 14:
                start, end = 2 * self.diameter, 15 * self.diameter
                major_moons = seed(1)
                if self._orbit <= TENTH_AU:
                    major_moons = 0
                elif self._orbit <= HALF_AU:
                    major_moons -= 5
                elif self._orbit <= THREE_QUARTERS_AU:
                    major_moons -= 4
                elif self._orbit <= ONE_HALF_AU:
                    major_moons -= 1
                major_moons = max(major_moons, 0)
                moon_type = "Terrestrial"
                mod = 12 if self._size >= 17 else 6
            else:
                start, end = 5 * self.diameter, 40 * self.diameter
                major_moons = roll.min_max("d6-4", 0)
                major_moons = get_terrestrial_moon_count(major_moons)
                moon_type = "Dwarf"
                mod = 0
            if major_moons > 0:
                generate_moons(major_moons, start, end, moon_type, mod)

        def get_moonlets():
            if self._size >= 14:
                start, end = 15 * self.diameter, 200 * self.diameter
                moonlets = seed(1)
                if self._orbit <= 0.5:
                    moonlets = 0
                elif self._orbit <= 0.75:
                    moonlets -= 5
                elif self._orbit <= 1.5:
                    moonlets -= 4
                elif self._orbit <= 3:
                    moonlets -= 1
                moon_type = "Dwarf"
                mod = 12 if self._size >= 17 else 6
            else:
                start, end = 1 * self.diameter, 5 * self.diameter
                moonlets = (
                    0 if len(satellites) > 0 else roll.min_max("d6-2", 0)
                )
                moonlets = get_terrestrial_moon_count(moonlets)
                moon_type = "Asteroid"
                mod = 0
            if moonlets > 0:
                generate_moons(moonlets, start, end, moon_type, mod)

        determine_rings()
        get_major_moons()
        get_moonlets()
        return satellites

    def get_rotational_period(self, star_mass) -> float:
        def check_tidal_breaking():
            if self._orbit != 0:
                tidal_break = (0.46 * star_mass * self.diameter) / self._orbit**3
            else:
                tidal_break = 0
            tidal_forces = tidal_break + self.satellite_tidal_forces
            total_tidal_force = round(
                tidal_forces * self._age / self.total_mass
            )
            return total_tidal_force

        tidal = check_tidal_breaking()
        rotation = get_rotation(self._size_category, tidal)
        return rotation 

    def get_local_day(self, period, rotation):
        if period == rotation or period == float("inf"):
            return 0
        else:
            return (period * rotation) / (period - rotation)

    def get_axial_tilt(self):
        tilt = seed()
        if tilt >= 17:
            tilt += seed(1)
        axis = int(roll.bi_seek(tilt, star_data["AXIAL_TILT"])) + roll.math(
            "2d6-2"
        )
        return abs(variability(axis, 0.1))

    def get_geological_activity(
        self, planet_type, sat
    ) -> tuple[str, str, int]:
        if planet_type != "Terrestrial":
            return "None", "None", 0
        volcanic_roll = seed() + round(self.gravity / self._age * 40)
        if len(self.satellites) == 1:
            volcanic_roll += 5
        elif len(self.satellites) >= 2:
            volcanic_roll += 10
        elif sat == True:
            volcanic_roll += 5
        elif self._size_category == "Tiny" and self._type_data[
            "Planet_class"
        ] in [
            "Stygian",
            "Stygian (Moonlet)",
        ]:
            volcanic_roll += 60
        volcanic = roll.bi_seek(volcanic_roll, star_data["VOLCANIC_ACTIVITY"])

        if self._size <= 9:
            tectonic = "None"
        else:
            tectonic_roll = seed()
            if volcanic == "None":
                tectonic_roll -= 8
            elif volcanic == "Light":
                tectonic_roll -= 4
            elif volcanic == "Heavy":
                tectonic_roll += 4
            elif volcanic == "Extreme":
                tectonic_roll += 8
            if self._hydro_coverage < 50:
                tectonic_roll -= 2
            if planet_type == "Terrestrial":
                if len(self.satellites) == 1:
                    tectonic_roll += 2
                elif len(self.satellites) >= 2:
                    tectonic_roll += 4
            tectonic = roll.bi_seek(
                tectonic_roll, star_data["VOLCANIC_ACTIVITY"]
            )
        resource_mod = 0
        if volcanic == "None":
            resource_mod -= 2
        elif volcanic == "Light":
            resource_mod -= 1
        elif volcanic == "Heavy":
            resource_mod += 1
        elif volcanic == "Extreme":
            resource_mod += 2
        return volcanic, tectonic, resource_mod

    def get_desirability(self, size) -> int:

        def get_size_score() -> int:
            if size >= 14:
                score = -2
            elif (size >= 10 and self.atmo == 15) or size == 0:
                score = -1
            else:
                score = 0
            return score

        def get_atmo_score() -> int:
            score = 0
            if self.atmo in [6, 7]:
                score += 4
            elif self.atmo in [4, 5, 8, 9]:
                score += 3
            elif self.atmo in [2, 3]:
                score += 2
            elif 12 <= self.atmo <= 16:
                score -= 4
            else:
                score += 1
            if self.atmo in TAINTED_ATMOSPHERES:
                score -= 1
            return score

        def get_hydro_score() -> int:
            if self._hydro == 0:
                score = 0
            elif 91 <= self._hydro <= 60:
                score = 3
            elif self._hydro <= 90:
                score = 2
            else:
                score = 1
            return score

        def get_gravity_score() -> int:
            if size >= 10 and self.atmo == 15:
                score = -1
            elif 0.8 <= self.gravity <= 1.01:
                score = 3
            elif 1.01 < self.gravity <= 2:
                score = 1
            elif self.gravity > 2:
                score = -5
            else:
                score = 0
            return score

        def get_climate_score() -> int:
            if self._climate == "Cold":
                score = 1
            elif self._climate in [
                "Chilly",
                "Cool",
                "Normal",
                "Warm",
                "Tropical",
            ]:
                score = 3
            elif self._climate == "Hot":
                score = 1
            else:
                score = -15
            return score

        def get_habitable_score() -> int:
            if 5 <= size <= 10 and self.atmo > 3 and 4 <= self._hydro <= 8:
                score = 5
            elif 2 <= self.atmo <= 6 and self._hydro >= 3:
                score = 2
            else:
                score = 0
            if isinstance(self._parent, Star) and self._parent.flare == "e":
                score -= 2
            return score

        def get_geologic_score() -> int:
            score = 0
            if self.volcanic_activity == "Extreme":
                score = -2
            elif self.volcanic_activity == "Heavy":
                score = -1
            if self.tectonic_activity == "Extreme":
                score = -2
            elif self.tectonic_activity == "Heavy":
                score = -1
            return score

        size_score = get_size_score()
        atmo_score = get_atmo_score()
        hydro_score = get_hydro_score()
        gravity_score = get_gravity_score()
        goldilocks_score = get_climate_score()
        habitable_score = get_habitable_score()
        geologic_score = get_geologic_score()

        return sum(
            [
                size_score,
                atmo_score,
                hydro_score,
                gravity_score,
                goldilocks_score,
                habitable_score,
                geologic_score,
                self.resources,
            ]
        )


class Rogue_Planet(Planet):
    def __init__(self, system : StarSystem):
        planet_type = roll.bi_seek(seed(), star_data["ROGUE TYPE"])
        super().__init__(planet_type, 0, "inner", system)
        self._id = f"Rogue Planet @ {system.id}"
        self.orbit = "Rogue"

    def _get_blackbody(self):
        return variability(30)


class Asteroid(Space_Object):
    def __init__(self, ast_type, diameter):
        super().__init__()
        self._id = f"{diameter}km diameter asteroid, type {ast_type}"
        self.diameter = diameter
        self.type = ast_type
        self.composition = self.get_composition()
        self.density = self.get_density()
        self.albedo = self.get_albedo()
        self.total_mass = calculate_mass(self.diameter / 1000, self.density)
        self.rotation_period = round(self.calculate_rotation_period(), 2)
        self.desirability = self.get_desirability()

    def to_dict(self): 
        star_dict = {
            "ID": self._id,
            "Type": f"{self.type} type",
            "Diameter": f"{self.diameter} meters",
            "Rotational period": f"{self.rotation_period} hours",
            "Value": self.desirability,
        }
        return star_dict
    
    def get_composition(self):
        return star_data["COMPOSITIONS"][self.type]
    
    def get_density(self):
        return self.composition["density"]

    def get_albedo(self):
        lower, upper = self.composition["albedo"]
        albedo = random.uniform(lower, upper)
        return albedo

    def calculate_rotation_period(self):
        rotation_period = random.uniform(2, 24)
        return rotation_period

    def get_desirability(self):
        resources = int(roll.bi_seek(seed(), star_data["ASTEROID_RESOURCES"]))
        return resources


class Comet(Asteroid):
    def __init__(self, semi_major_axis, diameter, period, comet_type) -> None:
        super().__init__(comet_type, diameter)
        self._id = f"{diameter}km diameter comet with a period of {period} and a semi_major_axis of {semi_major_axis}"
        
    def get_composition(self) -> None:
        return None
    
    def get_albedo(self) -> float:
        return random.uniform(0.02, 0.06)
    
    def get_density(self) -> float:
        return roll.min_max("(2d6-1)/10", 0.5, 1.0)
    
    def calculate_rotation_period() -> float:
        rotation = seed()
        if rotation == 18: rotation += seed() * 2
        if rotation == 54: rotation += seed() * 2
        return variability(rotation + 1)

    def get_desirability() -> int:
        return -5


#class Centaur(Asteroid):


class Asteroid_Belt(Space_Object):
    def __init__(self, orbit, num_asteroids=100000) -> None:
        super().__init__()
        self._orbit = round(orbit, 2)
        self._id = f"Asteroid belt at {round(orbit, 2)} AU"
        self.size_distribution = {
            (500, 1000): 0,
            (100, 500): 0,
            (50, 100): 0,
            (10, 50): 0,
            (1, 10): 0,
        }
        self.largest_asteroids = []
        self.type_distribution = self.get_type_distribution(num_asteroids)
        self.type_percentages = self.get_type_percentages()
        self.desirability = self.get_desirability()

    def to_dict(self):
        star_dict = {
            "ID": self._id,
            "Type distributions": self.type_percentages,
            "Relative Value": round(self.desirability),
            "Significant Asteroids": [
                asteroid.to_dict() for asteroid in self.largest_asteroids
            ],
        }
        return star_dict

    def get_type_distribution(self, num_asteroids) -> dict[str, int]:
        asteroid_types = list(star_data["ASTEROID_TYPES"].keys())
        alt_weights = [
            ASTEROID_WEIGHT ** (i + 1) for i in range(len(asteroid_types))
        ]
        random.shuffle(alt_weights)
        weights = [
            alt_weights[i] * star_data["ASTEROID_TYPES"][asteroid_types[i]]
            for i in range(len(asteroid_types))
        ]
        distribution = {a_type: 0 for a_type in asteroid_types}
        largest_asteroids = []

        for _ in range(num_asteroids):
            asteroid_type = random.choices(
                population=asteroid_types, weights=weights, k=1
            )[0]
            distribution[asteroid_type] += 1
            asteroid_size, size_range = self.get_asteroid_size()
            self.size_distribution[size_range] += 1

            if asteroid_size > 500:
                largest_asteroids.append((asteroid_type, asteroid_size))
        for asteroid in largest_asteroids:
            major_asteroid = Asteroid(asteroid[0], asteroid[1])
            major_asteroid._orbit = self._orbit
            self.largest_asteroids.append(major_asteroid)
        return distribution

    def get_type_percentages(self) -> dict[str, float]:
        total = sum(self.type_distribution.values())
        percentages = {
            asteroid_type: f"{round((count / total) * 100, 2)}%"
            for asteroid_type, count in self.type_distribution.items()
        }
        sorted_percentages = dict(
            sorted(percentages.items(), key=lambda x: x[1], reverse=True)
        )
        return sorted_percentages

    def get_asteroid_size(self) -> tuple[int, tuple[int, int]]:
        sizes = {
            (500, 1000): 1,
            (100, 500): 10,
            (50, 100): 100,
            (10, 50): 1000,
            (1, 10): 10000,
        }
        size_range = list(sizes.keys())
        weights = list(sizes.values())

        a_range = random.choices(size_range, weights, k=1)[0]
        asteroid_size = random.randint(a_range[0], a_range[1])

        return asteroid_size, a_range

    def get_desirability(self):
        general_resources = int(
            roll.bi_seek(seed(), star_data["ASTEROID_RESOURCES"])
        )
        if len(self.largest_asteroids) > 0:
            large_asteroid_resources = (
                sum(
                    [
                        max(0, cast(Asteroid, asteroid).desirability)
                        for asteroid in self.largest_asteroids
                    ]
                )
                / len(self.largest_asteroids)
                / 2
            )
            return general_resources + large_asteroid_resources
        else:
            return general_resources


class Short_Period_Comets(Asteroid_Belt):
    def __init__(self, star):
        super().__init__(0, 1000)
        self.star : Star = star
        self._id = "Short Period Comets"
        self.size_distribution = {
            (10, 16): 0,
            (9, 10): 0,
            (6, 9): 0,
            (3, 6): 0,
            (1, 3): 0,
        }

    def get_type_distribution(self, num_comets) -> None:
        distribution = {size: 0 for size in self.size_distribution}
        largest_comets = []

        for _ in range(num_comets):
            comet_size, size_range = self.get_asteroid_size()
            self.size_distribution[size_range] += 1

            if comet_size > 10:
                largest_comets.append((comet_size))
        for comet in largest_comets:
            period = random.randint(20, 200)
            semi_major_axis =((period ** 2) / self.star._stellar_mass)  ** (1/3)
            major_comet = Comet(semi_major_axis, comet, period, "Short Period")
            self.largest_asteroids.append(major_comet)
        return distribution

    def get_asteroid_size(self) -> tuple[int, tuple[int, int]]:
        sizes = {
            (10, 16): 4,
            (9, 10): 6,
            (6, 9): 8,
            (3, 6): 9,
            (1, 3): 18,
        }
        c_range = roll.bi_seek(seed(), sizes)
        comet_size = random.randint(c_range[0], c_range[1])

        return comet_size, c_range

    def get_desirability(self):
        return 0


class Long_Period_Comets(Short_Period_Comets):
    def __init__(self, star):
        super().__init__(star)
        self._id = "Long Period Comets"
        self.size_distribution = {
            (64, 150) : 0,
            (32, 64) : 0,
            (20, 32): 0,
            (18, 20): 0,
            (12, 18): 0,
            (6, 12): 0,
            (1, 6): 0,
        }
        
    def get_type_distribution(self, num_comets) -> None:
        distribution = {size: 0 for size in self.size_distribution}
        largest_comets = []

        for _ in range(num_comets):
            comet_size, size_range = self.get_asteroid_size()
            self.size_distribution[size_range] += 1

            if comet_size > 20:
                largest_comets.append((comet_size))
        for comet in largest_comets:
            p_roll = LP_COMET * seed(4) + random.expovariate(0.1)
            period = variability(p_roll, 0.1)
            semi_major_axis =((period ** 2) / self.star._stellar_mass)  ** (1/3)
            major_comet = Comet(semi_major_axis, comet, period, "Short Period")
            self.largest_asteroids.append(major_comet)
        return distribution

    def get_asteroid_size(self) -> tuple[int, tuple[int, int]]:
        sizes = {
            (64, 150) : 3,
            (32, 64) : 4,
            (20, 32): 5,
            (18, 20): 6,
            (12, 18): 8,
            (6, 12): 9,
            (1, 6): 18,
        }
        c_range = roll.bi_seek(seed(), sizes)
        comet_size = random.randint(c_range[0], c_range[1])

        return comet_size, c_range


#class Trojans(Asteroid_Belt) 10 for terrestrial, 10000 for jovian/helian


#class Centaurs(Asteroid_Belt) 100000


class Population:
    def __init__(self) -> None:
        self._carrying_capacity = 0
        self.population, self.pop = 0, 0

    def get_carrying_capacity(self):
        carrying_capacity = seed(1)
        return (seed(2) - 2) ** carrying_capacity
    
    def get_population(self):
        pop_factor = random.uniform(0.6, 1)
        population = self._carrying_capacity * pop_factor
        return population, len(str(population)) - 1


class World_Population(Population):
    def __init__(self, world: Space_Object, outpost=False) -> None:
        super().__init__()
        self.world = world
        self.tech_level = self.get_tech()
        self._carrying_capacity = self.get_carrying_capacity()
        self.population, self.pop = self.get_population(outpost)    #temporary, fix when outpost pop done
        self.outpost_type = self.get_outpost_type() if outpost == True else None
        self.starport = self.get_spaceport(self.pop) if outpost == False else None
        self.factions, number = self.get_factions(outpost, self.pop)
        self.government = self.get_government(number)
        self.economics = self.get_economy(self.pop)
        self.largest_settlements = self.get_largest_settlements()

    def get_tech(self) -> int:
        min_tech = 0
        mod = 1 if self.world.desirability >= 4 else 0
        if isinstance(self.world, Planet):
            if self.world.atmo in TAINTED_ATMOSPHERES:
                min_tech = 4
            if self.world.atmo <= 1:
                min_tech == 7
        if isinstance(self.world, Asteroid_Belt | Asteroid):
            min_tech = 8
        tech_roll = seed() + mod
        if tech_roll != 3:
            tech = int(roll.bi_seek(tech_roll, star_data["TECH_LEVEL"]))
        else:
            tech = max(min(tech_roll, 7), min_tech)
        return tech

    def get_carrying_capacity(self) -> int:
        diameter = 0
        if self.world.desirability <= 3:
            carrying_capacity = 0
        else:
            carrying_capacity = float(
                roll.bi_seek(self.tech_level, star_data["CARRYING_CAPACITY"])
            )
        if self.world.desirability >= 10:
            multiplier = 1e3
        else:
            multiplier = float(
                roll.bi_seek(self.world.desirability, star_data["AFFINITY"])
            )
        if isinstance(self.world, Planet):
            diameter = self.world.diameter**2
        return round(carrying_capacity * multiplier * diameter)

    def get_population(self, outpost) -> tuple[int, int]:
        if self.world.homeworld == True:
            if self.tech_level <= 4:
                return int((seed(2) + 3) / 10 * self._carrying_capacity)
            else:
                return int(self._carrying_capacity * 10 / seed(2))
        else:
            affinity = 3 * self.world.desirability
            age = seed(2) * seed(2)
            if self.tech_level > 11:
                age *= seed(2)
            age = variability(age, 0.25) / 10
            pop_roll = seed() + affinity + age
            pop = int(np.exp((pop_roll - POP_CONS) / POP_MULT))
            pop = variability(pop, 0.25)
        scale = len(str(pop)) - 1
        return round(pop), scale

    def get_factions(self, outpost, pop) -> tuple[str, int]:
        if outpost == True:
            return "Organized", 1
        else:
            f_roll = 1
            if self.tech_level >= 8:
                f_roll += 1
            unity_level = seed(f_roll)
            if pop <= 7:
                unity_level += 8 - pop
            faction = roll.bi_seek(unity_level, star_data["UNITY"])
            number = seed(2)
            if faction == "Factionalized":
                number /= 2
            elif faction == "Coalition":
                number /= 3
            elif faction in ["World Government", "Opposed World Government"]:
                number /= 4
            return faction, round(number)

    def get_government(self, number) -> dict:
        if self.outpost_type:
            if self.outpost_type in GOVERNMENT_RUN:
                return "Government Run"
            elif self.outpost_type in CRIMINAL_RUN:
                return "Criminally Run"
            else: 
                return "Independent"
        mod = min(self.tech_level, 10)
        gov_types = {}
        if self.factions == "Diffuse":
            number *= 10
            while number > 0:
                gov_type = seed()
                selected_gov = roll.bi_seek(
                    gov_type + mod, star_data["GOVERNMENTS"]
                )
                variant = roll.bi_seek(seed(), star_data["VARIANT"])
                gov_types[f"{variant}{selected_gov}"] = (
                    gov_types.get(f"{variant}{selected_gov}", 0) + 1
                )
                number -= 1
            total_selections = sum(gov_types.values())
            for gov, count in gov_types.items():
                percentage = (count / total_selections) * 100
                gov_types[gov] = round(percentage, 2)
            overall_control = max((seed(2) - 7), 1)
            gov_types["Overall Control"] = overall_control
        else:
            while number > 0:
                gov_type = seed()
                selected_gov = roll.bi_seek(
                    gov_type + mod, star_data["GOVERNMENTS"]
                )
                variant = roll.bi_seek(seed() + mod, star_data["VARIANT"])
                relative_strength = seed(2)
                government_key = f"{variant}{selected_gov}"
                control = max((seed(2) - 7 + gov_type), 0) / 4
                gov_types[government_key] = (relative_strength, round(control))
                number -= 1
            gov_types = dict(
                sorted(gov_types.items(), key=lambda x: x[1], reverse=True)
            )
        return gov_types

    def get_economy(self, pop) -> int:
        base = int(roll.bi_seek(self.tech_level, star_data["INCOME"]))
        affinity = float(
            roll.bi_seek(self.world.desirability, star_data["AFF_MOD"])
        )
        pop_mod = float(roll.bi_seek(pop, star_data["POP_MOD"]))
        trade = base * affinity * pop_mod
        trade = variability(trade, 0.1)
        economy = int(roll.bi_search(trade, star_data["TRADE_LEVEL"]))
        return economy

    def get_spaceport(self, pop) -> str:
        if self.tech_level < 8:
            return None
        port_roll = seed()
        if (port_roll >= pop + 2 and pop >= 6 and self.tech_level >= 11) or self.world.desirability <= 0:
            return 3000000
        elif port_roll >= pop + 5 and pop >= 6 and self.tech_level >= 10:
            return 1000000
        elif port_roll >= pop + 8:
            return 300000
        elif port_roll >= pop + 7:
            return 100000
        elif port_roll >= 14:
            return 30000
        elif port_roll >= 12:
            return 10000
        elif port_roll >= 10:
            return 3000
        elif port_roll >= 8:
            return 1000

    def get_outpost_type(self) -> str:
        if isinstance(self.world, Asteroid | Asteroid_Belt):
            outpost_index = "BELT_OUTPOST_TYPE"
            outpost_roll = seed(2)
        else:
            outpost_index = "OUTPOST_INDEX"
            outpost_roll = seed()
        outpost_type = roll.bi_seek(outpost_roll, star_data[outpost_index])
        return outpost_type
    
    def get_largest_settlements(self) -> int:
        if self.population > 250000:
            number_of_settlements = seed(2)
            percent_of_pop = round(self.population * seed(2)/100) - (10000 * number_of_settlements)
        else:
            number_of_settlements = seed(1)
            percent_of_pop = random.uniform(0.5, 1.0) * self.population - (10000 * number_of_settlements)
            while self.population < percent_of_pop * number_of_settlements:
                number_of_settlements -= 1
                number_of_settlements = seed(1)
                percent_of_pop = random.uniform(0.8, 1) * self.population - (10000 * number_of_settlements)
        largest_settlements = [10000] * number_of_settlements
        total_largest_settlement_pop = sum(largest_settlements)
        while total_largest_settlement_pop < percent_of_pop:
            index = random.randint(0, number_of_settlements - 1)
            largest_settlements[index] += 10000
            total_largest_settlement_pop = sum(largest_settlements)
        return largest_settlements


class Station_Population(Population):
    def __init__(self, world, tech_level, outpost_type):
        super().__init__(world, tech_level)
        self.outpost_type = outpost_type


class Outpost_Population(Population):
    def __init__(self, world, tech_level, outpost_type):
        super().__init__(world, tech_level)
        self.outpost_type = outpost_type

    def get_population(self):
        pop = int(np.exp((seed(2) - POP_CONS) / POP_MULT))
        population = variability(pop, 0.25)
        scale = len(str(population)) - 1
        return round(population), scale
    

class Settlement_Population(Population):
    def __init__(self, world):
        super().__init__()

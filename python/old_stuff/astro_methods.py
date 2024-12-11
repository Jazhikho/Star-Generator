import roll
import random
import numpy as np

'''
Constants
'''
PI = np.pi
G_ASTRO = 39.478
R_EARTH = 6378.1
M_SUN = 1.989e30
TO_SUN = 3.0034893488507934e-06
VII_RADIUS = 0.0127
SIGMA = 5.67e-8
SUBGIANT_TEMP_MOD = 4800
STELLAR_RADIUS = 155000
INNER_LIMIT = 0.1
OUTER_LIMIT = 40
SNOW_LINE = 4.85
ZONE_FACTOR = 3
TENTH_AU = 0.1
HALF_AU = 0.5
THREE_QUARTERS_AU = 0.75
ONE_HALF_AU = 1.5
ASTEROID_WEIGHT = 1.3
BLACKBODY = 278
DENSE_ATMO = 0.07
POP_MULT = 10
POP_CONS = -60
LP_COMET = 50

OB_A = -0.000524
OB_B = 0.14257
OB_C = 5.33689

'''
HELPER FUNCTIONS
'''

def variability(amount, factor=0.05):
    fudge = random.uniform(1 - factor, 1 + factor)
    amount = float(amount)
    amount = amount + fudge * amount
    return amount

def seed(factor=3):
    seed = roll.dice(f'{factor}d6')
    return seed

'''
SCIENTIFIC FUNCTIONS
'''

def calculate_diameter(size):
    diameter = 0.1 * 1.295 ** (size)
    return variability(diameter)

def calculate_mass(diameter, density):
    volume = (4 / 3) * PI * ((diameter / 2) ** 3)
    mass = volume * density 
    return mass

def get_orbit(radius, distance):
    orbit = round(radius * distance * seed(2))
    return variability(orbit, 0.5)

def get_period(orbit, mass, sat=False) -> float:
    if orbit == 0:
        return float("inf")
    else:
        adjust_to_day = 1 if sat == True else 365   #periods in days
        return adjust_to_day * (orbit ** 3 / mass) ** 0.5   

def get_rotation(size, tidal, sat=False):   #hours
    if size == "Tiny": mod = 18
    elif size == "Small": mod = 14
    elif size == "Standard": mod = 10
    elif size == "Large": mod = 6
    else: mod = 0
    base = seed()
    retro = 4 if sat == True else 0
    retrograde = (-1) if seed() >= 13 + retro else variability(1)
    rotation = base + tidal + mod
    if base >= 16 or rotation > 36:
        new_rotation = seed(2)
        if new_rotation == 7: rotation = seed(1) * 48 
        if new_rotation == 8: rotation = seed(1) * 120
        if new_rotation == 9: rotation = seed(1) * 240
        if new_rotation == 10: rotation = seed(1) * 480
        if new_rotation == 11: rotation = seed(1) * 1200
        if new_rotation == 12: rotation = seed(1) * 2400
    rotation = rotation * retrograde
    return rotation

'''
DICTIONARY DEFINITIONS AND LISTS
'''

GOVERNMENT_RUN = [
    "Espionage Facility", "Government Research Station", 
    "Naval Base", "Prison", "Patrol Base"]

ATMO_CLASS = {
    "Trace" : 1,
    "Very Thin" : 3,
    "Thin" : 5,
    "Standard" : 7,
    "Dense" : 9,
    "Very Dense" : 11,
    "Superdense" : 16,
}

CRIMINAL_RUN = ["Pirate Base", "Rebel Base", "Black Market"]

ADDITIONAL_MODULES = [
    "shipbreaking", "library", "gaming_space", "extended_sensors", 
    "research_facility", "manufacturing", "extended_communications", 
    "drone_bay"
    ]

PLANET_SIZE_CATEGORY = {
    "Tiny" : [0, 1, 2, 3, 4],
    "Small": [5, 6, 7, 8],
    "Standard": [9, 10, 11, 12],
    "Large": [13, 14, 15, 16],
    "Giant": [17, 18, 19, 20, 21],
    "Super-Giant": [22, 23, 24, 25, 26]
}

TAINTED_ATMOSPHERES = [2, 4, 6, 8, 10, 11, 12, 13, 15]

ATMO_MOD = ["Arid", "Hebean", "Oceanic", "Promethean", "Tectonic", "Vesperian"]

HYDRO_MOD = ["Arean", "Hebean", "Rockball"]

BIO_CHEM = [
    "Arean", "Arid", "Jovian", "Tectonic", "Oceanic", "Promethean", "Snowball",
    "Panthalassic", "Vesperian"
]

ADJ_ATMO = ["Arid", "Oceanic", "Promethean", "Tectonic", "Vesperian"]

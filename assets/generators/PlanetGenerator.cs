using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using Generator;
using StellarLibraries;

public class PlanetGenerator
{
	private AtmosphereGenerator atmosphereGen;
	private HydrosphereGenerator hydrosphereGen;
	private BiochemistryGenerator biochemGen;
	private ClimateCalculator climateCalc;
	private SatelliteSystem satelliteSys;
	private PlanetBasics planetBasics;
	private OrbitalDynamics orbitalDynamics;

	public PlanetaryData PlanetaryData { get; private set; }

	public void Planet(string planetType, float planetOrbit, StarData planetStar, string planetZone, 
				  bool isSatellite = false, float parentMass = 0)
	{
		GeneratePlanet(planetType, planetOrbit, planetStar, planetZone, isSatellite, parentMass);
	}

	private void GeneratePlanet(string planetType, float planetOrbit, StarData parentStar, 
								string planetZone, bool isSatellite, float parentMass)
	{
		PlanetaryData data = new PlanetaryData
		{
			Orbit = planetOrbit,
			Zone = planetZone
		};

		data.SpectralType = parentStar.SpectralType[0].ToString();
		data.LuminosityClass = parentStar.LuminosityClass;
		data.Age = parentStar.Age;
		data.StarMass = parentStar.Mass;
		data.ParentMass = isSatellite ? parentMass : data.StarMass;

		// Get planet class and type data
		data.PlanetClass = GetPlanetClass(planetType, planetZone);
		var typeData = (Dictionary<string, object>)PlanetsData.TYPE_DATA[data.PlanetClass];

		// Generate physical characteristics
		planetBasics = new PlanetBasics();
		var basicData = planetBasics.GenerateBasics((Dictionary<string, object>)typeData, planetZone);
		data.Size = basicData.Size;
		data.SizeCategory = basicData.SizeCategory;
		data.Density = basicData.Density;
		data.Diameter = basicData.Diameter;
		data.Mass = basicData.Mass;
		data.Gravity = basicData.Gravity;

		// Generate orbital dynamics
		orbitalDynamics = new OrbitalDynamics();
		var orbitalData = orbitalDynamics.GenerateDynamics(planetOrbit, data.ParentMass, data.Mass, isSatellite);
		data.Eccentricity = orbitalData.Eccentricity;
		data.OrbitalPeriod = orbitalData.OrbitalPeriod;
		data.AxialTilt = orbitalData.AxialTilt;

		// Generate atmosphere
		atmosphereGen = new AtmosphereGenerator();
		var atmoData = atmosphereGen.GenerateAtmosphere((Dictionary<string, object>)typeData, data.Size, data.LuminosityClass, data.SpectralType);
		data.Atmosphere = atmoData.Atmosphere;
		data.AtmoMass = atmoData.AtmoMass;
		data.AtmoComposition = atmoData.AtmoComposition;

		hydrosphereGen = new HydrosphereGenerator();
		data.Hydrology = hydrosphereGen.GenerateHydrosphere((Dictionary<string, object>)typeData, data.Size, planetZone, data.SpectralType, (int)data.Atmosphere);

		biochemGen = new BiochemistryGenerator();
		var biochemData = biochemGen.GenerateBiochemistry((Dictionary<string, object>)typeData, data.Size, planetZone, data.SpectralType, data.LuminosityClass, (int)data.Atmosphere, data.Age);
		data.Biosphere = biochemData.Biosphere;
		data.Chemistry = biochemData.Chemistry;

		CompleteGeneration(data, typeData, isSatellite, parentStar);
	}

	private void CompleteGeneration(PlanetaryData data, Dictionary<string, object> typeData, bool isSatellite, StarData parentStar)
	{
		var adjAtmo = atmosphereGen.AdjustAtmoForBio(typeData, int.Parse(data.Biosphere.ToString()), data.Chemistry, int.Parse(data.Atmosphere.ToString()));
		if (adjAtmo.Atmosphere != data.Atmosphere)
		{
			data.Atmosphere = adjAtmo.Atmosphere;
			data.AtmoMass = adjAtmo.AtmoMass;
			data.AtmoComposition = adjAtmo.AtmoComposition;
		}

		climateCalc = new ClimateCalculator();
		var climateData = climateCalc.CalculateClimate(
			typeData, 
			data.Orbit, 
			data.LuminosityClass, 
			data.AtmoMass, 
			new Dictionary<string, object> 
			{
				["mass"] = parentStar.Mass,
				["luminosity"] = parentStar.Luminosity,
				["blackbody"] = data.Blackbody,
				["diameter"] = parentStar.Radius * 2,
				["absorption"] = data.Absorption,
				["eccentricity"] = data.Eccentricity
			}
		);
		data.Blackbody = climateData.Blackbody;
		data.Temperature = climateData.Temperature;
		data.Climate = climateData.Climate;
		data.Absorption = climateData.Absorption;

		// Generate satellites if applicable
		if (data.Size > 5 && !isSatellite)
		{
			satelliteSys = new SatelliteSystem(); // Removed the data parameter
			
			var parentStarDict = new Dictionary<string, object>
			{
				["mass"] = parentStar.Mass,
				["luminosity"] = parentStar.Luminosity,
				["blackbody"] = data.Blackbody,
				["diameter"] = parentStar.Radius * 2,
				["absorption"] = data.Absorption,
				["eccentricity"] = data.Eccentricity,
				["spectralType"] = parentStar.SpectralType,
				["luminosityClass"] = parentStar.LuminosityClass,
				["age"] = parentStar.Age,
				["radius"] = parentStar.Radius
			};
			data.Satellites = satelliteSys.GenerateSatellites(data.Size, data.Diameter, data.Orbit, data.Zone, parentStarDict, data.Mass);
		}
		else
		{
			data.Satellites = new List<object>();
		}

		// Calculate rotation and tidal effects
		float tidalBreaking;
		if (!isSatellite)
		{
			tidalBreaking = orbitalDynamics.CheckTidalBreaking(data.StarMass, data.Diameter, data.Orbit, data.Mass, data.Age, data.Satellites);
		}
		else
		{
			tidalBreaking = orbitalDynamics.GetTotalTidalForce(
				orbitalDynamics.GetTidalMass(data.ParentMass, data.Orbit, data.Diameter), data.Age, data.Diameter);
		}
		data.RotationalPeriod = orbitalDynamics.CalculateRotation(data.Size, tidalBreaking, data.OrbitalPeriod, isSatellite);
		data.DayLength = orbitalDynamics.GetLocalDay(data.OrbitalPeriod, data.RotationalPeriod);

		if (data.RotationalPeriod == 0)
		{
			var tidalData = atmosphereGen.AdjustForTidalLock((int)data.Atmosphere, data.Hydrology, data.Temperature);
			data.Atmosphere = tidalData.Atmosphere;
			data.AtmoMass = atmosphereGen.GetAtmoMass((int)data.Atmosphere);
			data.Hydrology = tidalData.Hydrology;
			data.Temperature = tidalData.Temperature.Day;
		}

		GetGeologicActivity(data, isSatellite);
		
		PlanetaryData = data;
	}
	
	//private int CalculateDesirability()
	//{
		//int resourceValue = DesirabilityCalculator.CalculateResourceValue(false);
		//int habitabilityModifier = DesirabilityCalculator.CalculateHabitabilityModifier(PlanetaryData);
		//
		//return resourceValue + habitabilityModifier;
	//}

	private void GetGeologicActivity(PlanetaryData data, bool isSatellite)
	{
		if (data.PlanetType != "Terrestrial") return;

		GetVolcanicActivity(data, isSatellite);
		GetTectonicActivity(data);
	}

	private void GetVolcanicActivity(PlanetaryData data, bool isSatellite)
	{
		int volcanicRoll = GD.RandRange(1, 100) + Mathf.RoundToInt(data.Gravity / data.Age * 40);
		
		if (data.Satellites.Count > 0)
		{
			volcanicRoll += data.Satellites.Count == 1 ? 5 : 10;
			if (data.SizeCategory == "Tiny" && 
				(data.PlanetClass == "Stygian" || data.PlanetClass == "Stygian (Moonlet)"))
			{
				volcanicRoll += 60;
			}
		}
		else if (isSatellite && data.ParentMass >= 10)
		{
			volcanicRoll += 5;
		}

		var volcanicActivityDict = (Dictionary<string, int>)PlanetsData.VOLCANIC_ACTIVITY;
		data.VolcanicActivity = Roll.Seek(volcanicActivityDict, volcanicRoll);
	}

	private void GetTectonicActivity(PlanetaryData data)
	{
		if (data.Size <= 9)
		{
			data.TectonicActivity = "None";
			return;
		}

		int tectonicRoll = GD.RandRange(1, 100);

		switch (data.VolcanicActivity)
		{
			case "None": tectonicRoll -= 8; break;
			case "Light": tectonicRoll -= 4; break;
			case "Heavy": tectonicRoll += 4; break;
			case "Extreme": tectonicRoll +=8; break;
		}

		if (data.Hydrology < 5) tectonicRoll -= 2;
		if (data.Satellites.Count == 1) tectonicRoll += 2;
		else if (data.Satellites.Count >= 2) tectonicRoll += 4;

		var tectonicActivityDict = (Dictionary<string, int>)PlanetsData.TECTONIC_ACTIVITY;
		data.TectonicActivity = Roll.Seek(tectonicActivityDict, tectonicRoll);
	}

	private string GetPlanetClass(string planetType, string planetZone, int mod = 0)
	{
		var worldClasses = PlanetsData.WORLD_CLASSES;
		if (!worldClasses.TryGetValue(planetType, out var planetTypeClasses))
		{
			throw new ArgumentException($"Invalid planet type: {planetType}");
		}

		if (!planetTypeClasses.TryGetValue(planetZone, out var zoneClasses))
		{
			throw new ArgumentException($"Invalid planet zone: {planetZone}");
		}

		return Roll.Seek(zoneClasses, Roll.Dice(1, 36) + Roll.Dice(mod));
	}
}

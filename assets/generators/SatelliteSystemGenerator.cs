using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using Generator;
using StellarLibraries;

public class SatelliteSystem
{
	private OrbitalLimits orbitalLimits;
	private Dictionary<string, object> parentStar;
	private string zone;
	private float planet;
	private float diameter;

	public SatelliteSystem()
	{
		orbitalLimits = new OrbitalLimits();
	}

	public List<object> GenerateSatellites(int size, float _diameter, float orbit, 
		string _zone, Dictionary<string, object> _parentStar, float _planet)
	{
		parentStar = _parentStar;
		zone = _zone;
		planet = _planet;
		diameter = _diameter;

		var rings = GetRings(size, orbit);
		var majorMoons = GetMajorMoons(size, orbit);
		var minorMoons = GetMoonlets(size, orbit);

		return new List<object> { rings, majorMoons, minorMoons };
	}

	private List<object> GetRings(int size, float orbit)
	{
		var ringSystem = new List<object>();
		if (!orbitalLimits.CanHaveRings(size, orbit, zone))
			return ringSystem;
		
		float probRings = 5 + 2.5f * size;
		float probSpecRings = size >= 8 ? (5.0f / 3.0f) * (size - 8) : 0;
		
		float totalProb = probRings + probSpecRings;
		if (totalProb > 100)
		{
			probRings = (probRings / totalProb) * 100;
			probSpecRings = (probSpecRings / totalProb) * 100;
		}

		var rings = Roll.Choice(
			new string[] { null, "Simple", "Complex" },
			new float[] 
			{ 
				Math.Max(100 - probRings - probSpecRings, 0) / 100,
				probRings / 100,
				probSpecRings / 100
			}
		);
		
		if (rings != null)
		{
			var ringLimits = orbitalLimits.CalculateRingLimits(diameter);
			
			if (rings == "Simple")
			{
				float ringOrbit = (float)Math.Round((ringLimits.Inner + ringLimits.Outer) / 2, 2);
				ringSystem = new List<object> { rings, ringOrbit };
			}
			else if (rings == "Complex")
			{
				ringSystem = new List<object> 
				{ 
					rings, 
					(float)Math.Round(ringLimits.Inner, 2), 
					(float)Math.Round(ringLimits.Outer, 2) 
				};
			}
		}
		return ringSystem;
	}

	private List<object> GetMajorMoons(int size, float orbit)
	{
		var satelliteLimits = orbitalLimits.CalculateSatelliteLimits(size, diameter, orbit);
		var moonData = orbitalLimits.CalculateMajorMoonsCount(size, orbit);
		float rocheLimit = orbitalLimits.CalculateRocheLimit(planet, diameter/2);
		
		satelliteLimits.MajorMoons.Start = Math.Max(satelliteLimits.MajorMoons.Start, rocheLimit);
		
		if (moonData.Count > 0 && satelliteLimits.MajorMoons.Start < satelliteLimits.MajorMoons.End)
		{
			return GenerateMoons(moonData.Count, satelliteLimits.MajorMoons.Start, 
				satelliteLimits.MajorMoons.End, moonData.Type, moonData.Mod);
		}
		else
		{
			return new List<object>();
		}
	}

	private List<object> GetMoonlets(int size, float orbit)
	{
		var satelliteLimits = orbitalLimits.CalculateSatelliteLimits(size, diameter, orbit);
		var moonData = orbitalLimits.CalculateMoonletsCount(size, orbit);
		float rocheLimit = orbitalLimits.CalculateRocheLimit(planet, diameter/2);
		
		satelliteLimits.Moonlets.Start = Math.Max(satelliteLimits.Moonlets.Start, rocheLimit);
		
		if (moonData.Count > 0 && satelliteLimits.Moonlets.Start < satelliteLimits.Moonlets.End)
		{
			return GenerateMoons(moonData.Count, satelliteLimits.Moonlets.Start, 
				satelliteLimits.Moonlets.End, moonData.Type, moonData.Mod);
		}
		else
		{
			return new List<object>();
		}
	}

	private List<object> GenerateMoons(int moons, float start, float end, string moonType, int mod)
	{
		var planetPositions = new List<float>();
		var moonArray = new List<object>();
		var random = new Random();

		while (planetPositions.Count < moons)
		{
			float position = (float)random.NextDouble() * (end - start) + start;
			if (planetPositions.All(pos => Math.Abs(position - pos) >= 1))
			{
				planetPositions.Add(position);
			}
			else
			{
				moons--;
			}
		}
		
		foreach (float moonOrbit in planetPositions)
		{
			var moonParentStar = new StarData
			{
				Mass = Convert.ToSingle(parentStar["mass"]),
				Luminosity = Convert.ToSingle(parentStar["luminosity"]),
				SpectralType = parentStar.ContainsKey("spectralType") ? (string)parentStar["spectralType"] : "",
				LuminosityClass = Convert.ToInt32(parentStar.GetValueOrDefault("luminosityClass", 0)),
				Age = Convert.ToSingle(parentStar.GetValueOrDefault("age", 0f)),
				Radius = Convert.ToSingle(parentStar.GetValueOrDefault("radius", 0f))
			};
			
			var planetGen = new PlanetGenerator();
			planetGen.Planet(moonType, moonOrbit, moonParentStar, zone, true, planet);
			moonArray.Add(planetGen.PlanetaryData);
		}
		
		return moonArray;
	}
}

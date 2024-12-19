using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using Generator;
using StellarLibraries;

public class SystemGenerator
{
	public List<StarData> Stars { get; private set; } = new List<StarData>();
	private SystemArrangement starArrangement;
	private SystemBody systemBody;
	private OrbitalLimits orbitalLimits;

	public SystemGenerator()
	{
		InitializeSystems();
		GenerateSystem();
	}

	private void InitializeSystems()
	{
		starArrangement = new SystemArrangement();
		systemBody = new SystemBody();
		orbitalLimits = new OrbitalLimits();
	}

	private void GenerateSystem()
	{
		int starCount = starArrangement.DetermineStarCount();
		GD.Print($"Generating {starCount} stars");
		GenerateStarsData(starCount);
		Stars = starArrangement.ArrangeStars(Stars, orbitalLimits);
		GenerateCelestialBodiesData();
	}

	private void GenerateStarsData(int starCount)
	{
		float massCap = float.MaxValue;
		
		for (int i = 0; i < starCount; i++)
		{
			GD.Print($"Creating star {i} of {starCount}");
			var starGenerator = new StarGenerator(i, massCap);
			var starData = starGenerator.StarData;
			GD.Print($"Star Data: {starData}");
			if (starData != null)
			{
				Stars.Add(starData);
				if (i == 1 && (starData.LuminosityClass == 7 || starData.Mass <= 0.2f))
				{
					break;
				}
				else
				{
					massCap = starData.Mass;
				}
			}
		}
	}

	private void GenerateCelestialBodiesData()
	{
		foreach (var star in Stars)
		{
			if (star == null)
			{
				GD.Print("Encountered a null star in Stars list.");
				continue;
			}

			var limits = star.OrbitalLimits;
			if (limits == null)
			{
				GD.Print($"OrbitalLimits is null for star: {star.SpectralType}{star.LuminosityClass}");
				continue;
			}

			List<float> orbits;
			try
			{
				orbits = orbitalLimits.GenerateOrbits(limits.Inner, limits.Outer);
			}
			catch (Exception e)
			{
				GD.Print($"Error generating orbits: {e.Message}");
				continue;
			}

			star.CelestialBodies = new List<object>();

			foreach (var orbit in orbits)
			{
				string zone = orbit <= limits.SnowLine ? "inner" : "outer";
				string bodyType;
				try
				{
					bodyType = systemBody.DetermineBodyType(zone);
				}
				catch (Exception e)
				{
					GD.Print($"Error determining body type: {e.Message}");
					continue;
				}

				switch (bodyType)
				{
					case "Dwarf":
					case "Terrestrial":
					case "Helian":
					case "Jovian":
						try
						{
							var planetGen = new PlanetGenerator();
							planetGen.Planet(bodyType, orbit, star, zone);
							star.CelestialBodies.Add(planetGen.PlanetaryData);
						}
						catch (Exception e)
						{
							GD.Print($"Error generating planet: {e.Message}");
						}
						break;
					case "Asteroid Belt":
						try
						{
							var belt = new SmallBodyGroup.AsteroidBelt(orbit, 10000);
							star.CelestialBodies.Add(belt.Data);
						}
						catch (Exception e)
						{
							GD.Print($"Error generating asteroid belt: {e.Message}");
						}
						break;
					default:
						GD.Print($"Unknown body type: {bodyType}");
						break;
				}
			}
		}
	}
}

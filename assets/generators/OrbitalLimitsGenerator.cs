using Godot;
using System;
using System.Collections.Generic;
using Generator;
using StellarLibraries;

public class OrbitalLimits
{
	private const float TENTH_AU = 0.1f;
	private const float HALF_AU = 0.5f;
	private const float THREE_QUARTERS_AU = 0.75f;
	private const float ONE_HALF_AU = 1.5f;
	private const float EARTH_DIAMETER_TO_AU = 0.000085f;

	private static readonly Dictionary<string, int> ORBITAL_SPACING = new Dictionary<string, int>
	{
		{ "1.4", 4 }, { "1.5", 6 }, { "1.6", 8 }, { "1.7", 12 }, { "1.8", 14 }, { "1.9", 16 }, { "2.0", 18 }
	};

	public List<float> GenerateOrbits(float innerLimit, float outerLimit)
	{
		var orbits = new List<float>();
		float orbit = innerLimit * Roll.Dice() / 3.5f;

		while (orbit < outerLimit)
		{
			orbits.Add(orbit);
			float spacing = float.Parse(Roll.Seek(ORBITAL_SPACING));
			orbit *= spacing;
		}

		return orbits;
	}

	public OrbitalLimitsData CalculateOrbitalLimits(StarData starData, float distance = float.PositiveInfinity)
	{
		float mass = starData.Mass;
		float luminosity = starData.Luminosity;

		float innerLimit = CalculateInnerLimit(mass);
		float outerLimit = CalculateOuterLimit(mass);
		float snowLine = CalculateSnowLine(luminosity);

		if (distance <= 30000)
		{
			var adjustedLimits = AdjustForForbiddenZone(distance, innerLimit, outerLimit);
			innerLimit = adjustedLimits[0];
			outerLimit = adjustedLimits[1];
		}

		return new OrbitalLimitsData
		{
			Inner = innerLimit,
			Outer = outerLimit,
			SnowLine = snowLine
		};
	}

	private float CalculateInnerLimit(float mass) => Roll.Vary(0.1f * mass);
	private float CalculateOuterLimit(float mass) => Roll.Vary(40f * mass);
	private float CalculateSnowLine(float luminosity) => 4.85f * MathF.Sqrt(luminosity);

	public float CalculateRocheLimit(float mass, float radius)
	{
		return radius * MathF.Pow(2 * mass / radius, 1.0f / 3.0f);
	}

	private float[] AdjustForForbiddenZone(float distance, float inner, float outer)
	{
		float forbiddenInner = distance / 3.0f;
		float forbiddenOuter = distance * 3.0f;

		if (outer > forbiddenInner) outer = forbiddenInner;
		if (inner > forbiddenOuter) inner = forbiddenOuter;
		if (inner > outer) inner = outer;

		return new float[] { inner, outer };
	}

	public SatelliteLimits CalculateSatelliteLimits(int planetSize, float planetDiameter, float planetOrbit)
	{
		float majorMoonsStart, majorMoonsEnd, moonletsStart, moonletsEnd;

		if (planetSize >= 14)
		{
			majorMoonsStart = 3 * planetDiameter;
			majorMoonsEnd = 15 * planetDiameter;
			moonletsStart = 20 * planetDiameter;
			moonletsEnd = 200 * planetDiameter;
		}
		else
		{
			majorMoonsStart = 5 * planetDiameter * EARTH_DIAMETER_TO_AU;
			majorMoonsEnd = 40 * planetDiameter * EARTH_DIAMETER_TO_AU;
			moonletsStart = planetDiameter;
			moonletsEnd = 5 * planetDiameter;
		}

		return new SatelliteLimits
		{
			MajorMoons = new OrbitalRange { Start = majorMoonsStart, End = majorMoonsEnd },
			Moonlets = new OrbitalRange { Start = moonletsStart, End = moonletsEnd }
		};
	}

	public bool CanHaveRings(int planetSize, float planetOrbit, string zone)
	{
		return zone != "epistellar" && planetOrbit > HALF_AU;
	}

	public RingLimits CalculateRingLimits(float planetDiameter)
	{
		float orbit1 = Roll.Vary((Roll.Dice(1, 6, 4) / 4.0f) * planetDiameter);
		float orbit2 = Roll.Vary((Roll.Dice(1, 6, 4) / 4.0f) * planetDiameter);

		return new RingLimits
		{
			Inner = MathF.Min(orbit1, orbit2),
			Outer = MathF.Max(orbit1, orbit2)
		};
	}

	public MoonData CalculateMajorMoonsCount(int size, float orbit)
	{
		int majorMoons = CalculateMoons(size, orbit, out string moonType, out int mod);
		majorMoons = Math.Max(majorMoons, 0);
		return new MoonData { Count = majorMoons, Type = moonType, Mod = mod };
	}

	public MoonData CalculateMoonletsCount(int size, float orbit)
	{
		int moonlets = CalculateMoons(size, orbit, out string moonType, out int mod);
		moonlets = Math.Max(moonlets, 0);
		return new MoonData { Count = moonlets, Type = moonType, Mod = mod };
	}

	private int CalculateMoons(int size, float orbit, out string moonType, out int mod)
	{
		int moons;
		if (size >= 14)
		{
			moons = Roll.Dice(1);
			moonType = "Dwarf";
			mod = size >= 17 ? 12 : 6;
		}
		else
		{
			moons = Roll.Dice(1, 6, -2, 0, 4);
			moonType = "Asteroid";
			mod = 0;
		}
		return moons;
	}
}

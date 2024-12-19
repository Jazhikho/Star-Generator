using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using Generator;
using StellarLibraries;

public class OrbitalDynamics
{
	private static readonly Dictionary<string, int> ECCENTRICITY = new Dictionary<string, int>
	{
		{"0", 3}, {"0.05", 6}, {"0.1", 9}, {"0.15", 11}, {"0.2", 12},
		{"0.3", 13}, {"0.4", 14}, {"0.5", 15}, {"0.6", 16}, {"0.7", 17}, {"0.8", 18}
	};
	
	private static readonly Dictionary<string, int> NORMAL_TILT = new Dictionary<string, int>
	{
		{"0", 6}, {"10", 9}, {"20", 12}, {"30", 14}, {"40", 16}
	};

	private static readonly Dictionary<string, int> EXTREME_TILT = new Dictionary<string, int>
	{
		{"50", 6}, {"60", 9}, {"70", 12}, {"80", 14}
	};

	public OrbitalData GenerateDynamics(float orbit, float parentMass, float mass, bool isSatellite)
	{
		return new OrbitalData
		{
			Eccentricity = CalculateEccentricity(),
			OrbitalPeriod = CalculateOrbitalPeriod(orbit, parentMass, mass, isSatellite, isSatellite),
			AxialTilt = CalculateAxialTilt()
		};
	}

	public float CalculateEccentricity()
	{
		return Roll.Vary(float.Parse(Roll.Seek(ECCENTRICITY)));
	}

	public float DetermineSeparation(int mod, float? minSep)
	{
		int rand = Roll.Dice(3, 6, (int)Math.Pow(3, mod));
		float baseMultiplier = rand switch
		{
			<= 6 => 0.05f,
			<= 9 => 0.5f,
			<= 11 => 2.0f,
			<= 14 => 10.0f,
			_ => 50.0f
		};
		var separation = Roll.Vary(baseMultiplier * Roll.Dice(2, 6, (int)Math.Pow(2, mod), 12), 0.1f);
		return minSep.HasValue ? Math.Max(separation, minSep.Value * 1.2f) : separation;
	}

	public float CalculateOrbitalPeriod(float orbit, float parentMass, float selfMass, bool equalBodies, bool _sat = false)
	{
		if (orbit == 0) return float.PositiveInfinity;
		
		selfMass *= equalBodies ? 1.0f : 0.000003f;
		float sat = _sat ? (0.166f / 365.24f) : 1.0f;
		return sat * (float)Math.Pow(Math.Pow(orbit, 3) / (parentMass + selfMass), 0.5f);
	}

	private float CalculateAxialTilt()
	{
		int axialTiltRoll = Roll.Dice();
		string axialTilt = axialTiltRoll < 17 
			? Roll.Search(NORMAL_TILT, axialTiltRoll).ToString()
			: Roll.Search(EXTREME_TILT, Roll.Dice(1)).ToString();
		return Math.Clamp(Roll.Vary(int.Parse(axialTilt) + Roll.Dice(2, 6, -2)), 0, 90);
	}

	public float CalculateRotation(int size, float tidalBreaking, float orbitalPeriod, bool isSatellite)
	{
		int mod = size switch
		{
			<= 4 => 18,
			<= 8 => 14,
			<= 12 => 10,
			<= 16 => 6,
			_ => 0
		};
		
		int baseRoll = Roll.Dice();
		int retro = isSatellite ? 3 : 0;
		float retrograde = Roll.Dice() >= 14 + retro ? -1.0f : Roll.Vary(1.0f);
		float rotation = baseRoll + tidalBreaking + mod;
		
		if (baseRoll >= 16 || rotation > 36)
		{
			int newRotation = Roll.Dice(2);
			rotation = newRotation switch
			{
				7 => Roll.Dice(1) * 48,
				8 => Roll.Dice(1) * 120,
				9 => Roll.Dice(1) * 240,
				10 => Roll.Dice(1) * 480,
				11 => Roll.Dice(1) * 1200,
				12 => Roll.Dice(1) * 2400,
				_ => rotation
			};
		}
		
		rotation *= retrograde;
		
		if (rotation / 8765.76f >= orbitalPeriod)
			rotation = orbitalPeriod * 8765.76f;

		return rotation;
	}

	public float CheckTidalBreaking(float starMass, float diameter, float orbit, float mass, float age, 
	List<object> satellites)
	{
		float tidalBreak = (0.46f * starMass * diameter) / (float)Math.Pow(orbit, 3);
		float tidalForce = 0;
		float tidalMass = 0;
		
		if (satellites.Count > 1 && satellites[1] is List<object> moons && moons.Count > 0)
		{
			foreach (var moon in moons)
			{
				if (moon is PlanetaryData planetaryMoon)
				{
					float satOrbit = planetaryMoon.Orbit;
					tidalMass += GetTidalMass(planetaryMoon.Mass, satOrbit, diameter);
				}
			}
		}
		tidalForce = tidalBreak + tidalMass;
		return GetTotalTidalForce(tidalForce, age, mass);
	}

	public float GetTidalMass(float affectingBody, float distance, float diameter)
	{
		return 23300000 * (affectingBody * diameter) / (float)Math.Pow(distance, 3);
	}
	
	public float GetTotalTidalForce(float force, float age, float mass)
	{
		return (float)Math.Round(force * age / mass, 0);
	}

	public float GetLocalDay(float orbitalPeriod, float rotationalPeriod)
	{
		orbitalPeriod *= 8765.76f;
		if (orbitalPeriod == rotationalPeriod || orbitalPeriod == float.PositiveInfinity)
			return 0.0f;
		else
			return (orbitalPeriod * rotationalPeriod) / (orbitalPeriod - rotationalPeriod);
	}
}

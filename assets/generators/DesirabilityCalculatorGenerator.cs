using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using Generator;
using StellarLibraries;

public class DesirabilityCalculator
{
	public static readonly Dictionary<string, int> ASTEROID_RESOURCES = new()
	{
		{"-5", 3},
		{"-4", 4},
		{"-3", 5},
		{"-2", 7},
		{"-1", 9},
		{"0", 11},
		{"1", 13},
		{"2", 15},
		{"3", 16},
		{"4", 17},
		{"5", 18}
	};

	public static int CalculateResourceValue(bool isAsteroid)
	{
		int roll = Roll.Dice(3);
		
		if (isAsteroid)
		{
			return roll switch
			{
				<= 3 => -5,  // Worthless
				4 => -4,     // Very Scant
				5 => -3,     // Scant
				6 or 7 => -2, // Very Poor
				8 or 9 => -1, // Poor
				10 or 11 => 0, // Average
				12 or 13 => 1, // Abundant
				14 or 15 => 2, // Very Abundant
				16 => 3,      // Rich
				17 => 4,      // Very Rich
				_ => 5        // Motherlode
			};
		}
		else
		{
			return roll switch
			{
				<= 2 => -3,   // Scant
				3 or 4 => -2, // Very Poor
				5 or 6 or 7 => -1, // Poor
				>= 8 and <= 13 => 0, // Average
				14 or 15 or 16 => 1, // Abundant
				17 or 18 => 2, // Very Abundant
				>= 19 => 3    // Rich
			};
		}
	}

	public static int CalculateHabitabilityModifier(Dictionary<string, object> planetData)
	{
		int modifier = 0;
		string atmosphere = (string)planetData["atmosphere_type"];
		float hydrographics = Convert.ToSingle(planetData["hydrographics"]);
		string climate = (string)planetData["climate"];

		// Atmosphere modifiers
		modifier += atmosphere switch
		{
			"None" or "Trace" => 0,
			"Very Thin" or "Thin" or "Standard" or "Dense" or "Very Dense" or "Super Dense" 
				when atmosphere.Contains("Breathable") => CalculateBreathableAtmosphereModifier(atmosphere),
			_ when atmosphere.Contains("Suffocating") && atmosphere.Contains("Toxic") && atmosphere.Contains("Corrosive") => -2,
			_ when atmosphere.Contains("Suffocating") && atmosphere.Contains("Toxic") => -1,
			_ when atmosphere.Contains("Suffocating") => 0,
			_ => 0
		};

		// Hydrographics modifiers
		if (hydrographics > 0)
		{
			modifier += hydrographics switch
			{
				> 0 and < 0.6f => 1,
				>= 0.6f and <= 0.9f => 2,
				> 0.9f and < 1f => 1,
				_ => 0
			};
		}

		// Climate modifiers (only if atmosphere is breathable)
		if (atmosphere.Contains("Breathable"))
		{
			modifier += climate switch
			{
				"Cold" => 1,
				"Chilly" or "Cool" or "Normal" or "Warm" or "Tropical" => 2,
				"Hot" => 1,
				_ => 0
			};
		}

		return modifier;
	}

	private static int CalculateBreathableAtmosphereModifier(string atmosphere)
	{
		int modifier = atmosphere switch
		{
			"Very Thin" => 1,
			"Thin" => 2,
			"Standard" or "Dense" => 3,
			"Very Dense" or "Super Dense" => 1,
			_ => 0
		};

		if (!atmosphere.Contains("Marginal"))
		{
			modifier += 1;
		}

		return modifier;
	}
}

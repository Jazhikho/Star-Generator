using Godot;
using System;
using System.Collections.Generic;
using Generator;
using StellarLibraries;

public class StarBasics
{
	public Dictionary<string, float> CalculateMass(float massCap)
	{
		try
		{
			Console.WriteLine("Entering CalculateMass method");
			float massRoll = Roll.Dice();
			float resultMass = 0f;
			float resultMassVar = 0f;

			if (massRoll == 18)
			{
				var brownDwarfMass = StarsData.BROWN_DWARF["MASS"] as Dictionary<string, int>;
				resultMass = float.Parse(Roll.Search(brownDwarfMass).ToString());
				resultMassVar = resultMass;
			}
			else if (massRoll == 3 && Roll.Dice() <= 7 && massCap == float.PositiveInfinity)
			{
				resultMass = 3 + Roll.Expo(0.2f);
				resultMassVar = (float)Roll.Search(StarsData.MASS_MAP, (int)Snapped(resultMass, 1));
				return new Dictionary<string, float>
				{
					{ "mass", Roll.Vary(resultMass, 0.2f) },
					{ "mass_var", resultMassVar }
				};
			}
			else
			{
				string subRoll = Roll.Dice(3, 6, 0, 14).ToString();
				var stellarMass = StarsData.STELLAR_MASS[subRoll] as Dictionary<string, int>;
				resultMassVar = (float)Roll.Search(stellarMass);
				resultMass = resultMassVar;
			}

			if (massCap != float.PositiveInfinity && massCap < resultMass)
			{
				resultMass = Math.Max(0.01f, massCap - 0.01f * Roll.Dice(5, 6, -4));
				if (resultMass < 0.08f)
				{
					var brownDwarfMass = StarsData.BROWN_DWARF["MASS"] as Dictionary<string, int>;
					resultMassVar = (float)Roll.Search(brownDwarfMass);
				}
			}

			Console.WriteLine($"Calculated mass: {resultMass}, mass_var: {resultMassVar}");
			return new Dictionary<string, float>
			{
				{ "mass", resultMass },
				{ "mass_var", resultMassVar }
			};
		}
		catch (Exception e)
		{
			Console.WriteLine($"Error in CalculateMass: {e.Message}");
			return new Dictionary<string, float>
			{
				{ "mass", 1.0f },
				{ "mass_var", 0.0f }
			};
		}
	}

	private float Snapped(float value, int step)
	{
		return (float)Math.Round(value / step) * step;
	}
}

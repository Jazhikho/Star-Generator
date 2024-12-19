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
			GD.Print("Entering CalculateMass method");
			float massRoll = Roll.Dice();
			GD.Print($"Initial mass roll: {massRoll}");
			float resultMass;
			float resultMassVar = 0f;

			if (massRoll == 18)
			{
				GD.Print("Rolling for brown dwarf");
				var brownDwarfMass = StarsData.BROWN_DWARF["MASS"] as Dictionary<string, int>;
				resultMass = Roll.Search(brownDwarfMass);
				resultMassVar = resultMass;
			}
			else if (massRoll == 3 && Roll.Dice() <= 7 && massCap == float.PositiveInfinity)
			{
				GD.Print("Checking for massive star");
				var result = Roll.Vary(3 + Roll.Expo(0.2f));
				resultMassVar = (float)Roll.Search(StarsData.MASS_MAP, (int)Snapped(result, 1));
				return new Dictionary<string, float>
				{
					{ "mass", result},
					{ "mass_var", resultMassVar }
				};
			}
			else
			{
				string subRoll = Roll.Dice(3, 6, 0, 3, 14).ToString();
				GD.Print($"subRoll: {subRoll}");
				var stellarMass = StarsData.STELLAR_MASS[subRoll] as Dictionary<string, int>;
				GD.Print($"Dictionary: {stellarMass}");
				resultMassVar = Roll.Seek(stellarMass).ToFloat();
				GD.Print($"result mass: {resultMassVar}");
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

			GD.Print($"Calculated mass: {resultMass}, mass_var: {resultMassVar}");
			return new Dictionary<string, float>
			{
				{ "mass", resultMass },
				{ "mass_var", resultMassVar }
			};
		}
		catch (Exception e)
		{
			GD.Print($"Error in CalculateMass: {e.Message}");
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

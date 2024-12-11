using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using Generator;

public class StarTemperature
{
	public float CalculateMainSequenceTemperature(float baseTemp)
	{
		return Roll.Vary(baseTemp, 0.1f);
	}

	public float CalculateGiantTemperature()
	{
		return Roll.Vary(200 * Roll.Dice(2, 6, -2) + 3000);
	}

	public float CalculateSubgiantTemperature(float baseTemp, float tempDrop)
	{
		return Roll.Vary(baseTemp * (1.0f - tempDrop));
	}
}

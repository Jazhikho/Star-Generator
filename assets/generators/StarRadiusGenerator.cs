using Godot;
using System;
using Generator;

public class StarRadius
{
	public float CalculateMainSequenceRadius(float mass)
	{
		return mass < 1 ? Roll.Vary((float)Math.Pow(mass, 0.8)) : Roll.Vary((float)Math.Pow(mass, 0.5));
	}

	public float CalculateGiantRadius(float mass)
	{
		return Roll.Vary((float)Math.Pow(mass, 0.8) * Roll.Vary(10, 0.1f));
	}

	public float CalculateSubgiantRadius(float mass)
	{
		return Roll.Vary((float)Math.Pow(mass, 0.8) * Roll.Vary(2));
	}
}

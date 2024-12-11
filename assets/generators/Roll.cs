using Godot;
using System;
using System.Linq;
using System.Collections.Generic;

public static class Roll
{
	private static Random random = new Random();

	public static int Dice(int number = 3, int sides = 6, int modifier = 0, int low = int.MinValue, int high = int.MaxValue)
	{
		if (number <= 0 || sides <= 0) return 0;
		
		int total = Enumerable.Range(0, number)
			.Sum(_ => random.Next(1, sides + 1)) + modifier;
		
		return Math.Clamp(total, low, high);
	}

	public static float Vary(float amount, float factor = 0.05f)
	{
		float fudge = (float)random.NextDouble() * (2 * factor) + (1 - factor);
		return amount * fudge;
	}

	public static TKey Seek<TKey, TValue>(Dictionary<TKey, TValue> items, int? roll = null) where TValue : IComparable
	{
		if (roll == null) roll = Dice();
		
		var sortedItems = items.OrderBy(x => x.Value).ToList();
		
		foreach (var item in sortedItems)
		{
			if (roll <= Convert.ToInt32(item.Value))
			{
				return item.Key;
			}
		}
		
		return sortedItems.Last().Key;
	}

	public static TValue Search<TValue>(Dictionary<string, TValue> dictionary, object searchValue = null)
	{
		if (searchValue == null) searchValue = Dice();
		
		float searchFloat = ConvertToFloat(searchValue);
		var sortedKeys = dictionary.Keys
			.Select(k => new { Key = k, FloatKey = ConvertToFloat(k) })
			.OrderBy(x => x.FloatKey)
			.ToList();

		foreach (var keyPair in sortedKeys)
		{
			if (searchFloat <= keyPair.FloatKey)
			{
				return dictionary[keyPair.Key];
			}
		}

		return dictionary[sortedKeys.Last().Key];
	}
	
	private static float ConvertToFloat(object value)
	{
		if (value is float f) return f;
		if (value is int i) return i;
		if (value is double d) return (float)d;
		if (value is string s && float.TryParse(s, out float result)) return result;
		throw new ArgumentException($"Cannot convert {value} to float");
	}
	
	public static float Expo(float lambda)
	{
		return -(float)Math.Log(random.NextDouble()) / lambda;
	}

	public static T Choice<T>(T[] options, float[] probabilities)
	{
		if (options.Length != probabilities.Length)
			throw new ArgumentException("Options and probabilities must have the same length");

		float total = probabilities.Sum();
		float randomValue = (float)random.NextDouble() * total;
		float cumulativeProb = 0;

		for (int i = 0; i < options.Length; i++)
		{
			cumulativeProb += probabilities[i];
			if (randomValue <= cumulativeProb)
			{
				return options[i];
			}
		}

		return options[options.Length - 1];
	}
}

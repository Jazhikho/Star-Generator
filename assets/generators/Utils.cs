using System;
using System.Collections.Generic;

public static class Utils
{
	public static string SetKey(int value1, int value2, int value3)
	{
		return $"{value1},{value2},{value3}";
	}

	public static int GetAttr(Dictionary<string, object> typeData, string attr)
	{
		if (!typeData.TryGetValue(attr, out object attrRoll) || !(attrRoll is int[] rollParams))
			return 0;

		return Roll.Dice(rollParams[0], rollParams[1], rollParams[2]);
	}

	public static int AdjustedResults(int result, string attr, Dictionary<string, object> typeData)
	{
		string resultsKey = $"{attr}_results";
		if (!typeData.ContainsKey(resultsKey)) return result;

		if (!(typeData[resultsKey] is Dictionary<string, int[]> results))
			return result;

		if (!results.TryGetValue(result.ToString(), out int[] adjustParams))
			return result;

		return Roll.Dice(adjustParams[0], adjustParams[1], adjustParams[2]);
	}
}

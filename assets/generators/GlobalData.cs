using System;
using System.Collections.Generic;
using System.Numerics;
using Generator;

public class GlobalData
{
	private readonly object _lock = new object();

	public List<SystemData> SystemsData { get; private set; } = new List<SystemData>();
	public List<GalaxyData> GalaxyData { get; private set; } = new List<GalaxyData>();

	public void AddSystem(string sectorKey, string parsecKey, string id, List<StarData> systemData)
	{
		lock (_lock)
		{
			SystemsData.Add(new SystemData
			{
				Type = "system",
				SectorKey = sectorKey,
				ParsecKey = parsecKey,
				ID = id, 
				Data = systemData
			});
		}
	}

	public void AddGalaxyData(float x, float y, float z, string id, List<StarData> systemData)
	{
		GalaxyData.Add(new GalaxyData
		{
			Coordinates = new Vector3(x, y, z),
			ID = id, 
			SystemStars = systemData.Count,
			Luminosity = systemData[0].Luminosity,
			Temperature = systemData[0].Temperature
		});
	}

	public void ResetData()
	{
		SystemsData.Clear();
		GalaxyData.Clear();
	}
}

public struct SystemData
{
	public string Type;
	public string SectorKey;
	public string ParsecKey;
	public string ID;
	public object Data;
}

public struct GalaxyData
{
	public Vector3 Coordinates;
	public string ID;
	public int SystemStars;
	public float Luminosity;
	public float Temperature;
}

using Godot;
using System;
using System.Collections.Generic;
using System.Numerics;
using System.Text.Json.Serialization;
using Generator;

public class GlobalData
{
	private readonly object _lock = new object();
	private static GlobalData _instance;
	public static GlobalData Instance
	{
		get
		{
			if (_instance == null)
				_instance = new GlobalData();
			return _instance;
		}
	}
	
	[JsonPropertyName("systemsData")]
	public List<SystemData> SystemsData { get; set; } = new List<SystemData>();

	[JsonPropertyName("galaxyData")]
	public List<GalaxyData> GalaxyData { get; set; } = new List<GalaxyData>();

	public void AddSystem(string sectorKey, string parsecKey, string id, List<StarData> systemData)
	{
		lock (_lock)
		{
			GD.Print($"Adding system with ID: {id}, Data type: {systemData?.GetType()?.FullName ?? "null"}");
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
			Coordinates = new System.Numerics.Vector3(x, y, z),
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

public class SystemData
{
	[JsonPropertyName("type")]
	public string Type { get; set; }

	[JsonPropertyName("sectorKey")]
	public string SectorKey { get; set; }

	[JsonPropertyName("parsecKey")]
	public string ParsecKey { get; set; }

	[JsonPropertyName("id")]
	public string ID { get; set; }

	[JsonPropertyName("data")]
	public object Data { get; set; }
}

public class GalaxyData
{
	[JsonPropertyName("coordinates")]
	public System.Numerics.Vector3 Coordinates { get; set; }

	[JsonPropertyName("id")]
	public string ID { get; set; }

	[JsonPropertyName("systemStars")]
	public int SystemStars { get; set; }

	[JsonPropertyName("luminosity")]
	public float Luminosity { get; set; }

	[JsonPropertyName("temperature")]
	public float Temperature { get; set; }
}

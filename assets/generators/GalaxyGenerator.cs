using Godot;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Generator;

public class GalaxyGenerator
{
	public event Action<float, string> GenerationProgress;
	public event Action GenerationCompleted;
	private int totalParsecs;
	private int systemCount;
	//private int anomalyCount;
	private GlobalData globalData;

	private int xSectors;
	private int ySectors;
	private int zSectors;
	private int parsecsPerSector;
	private float systemChance;
	private float anomalyChance;

	public GalaxyGenerator(GlobalData globalData)
	{
		this.globalData = globalData;
	}

	public void GenerateGalaxy(int _x, int _y, int _z, int _parsecs, float _system, float _anomaly)
	{
		Console.WriteLine("Starting galaxy generation");
		globalData.ResetData();

		xSectors = _x;
		ySectors = _y;
		zSectors = _z;
		parsecsPerSector = _parsecs;
		systemChance = _system;
		anomalyChance = _anomaly;

		totalParsecs = xSectors * ySectors * zSectors * (int)Math.Pow(parsecsPerSector, 3);
		int processedParsecs = 0;
		systemCount = 0;

		var random = new Random();

		for (int x = 0; x < xSectors; x++)
		for (int y = 0; y < ySectors; y++)
		for (int z = 0; z < zSectors; z++)
		{
			string sectorKey = Utils.SetKey(x, y, z);
			Console.WriteLine($"Processing sector {sectorKey}");
			
			for (int px = 0; px < parsecsPerSector; px++)
			for (int py = 0; py < parsecsPerSector; py++)
			for (int pz = 0; pz < parsecsPerSector; pz++)
			{
				processedParsecs++;
				
				string parsecKey = Utils.SetKey(px, py, pz);
				string id = $"{sectorKey}-{parsecKey}";
				
				if (random.NextDouble() * 100 < systemChance)
				{
					Console.WriteLine($"System at {id}");
					var systemGenerator = new SystemGenerator();
					if (systemGenerator.Stars.Count > 0)
					{
						Console.WriteLine($"System generated with {systemGenerator.Stars.Count} stars");
						globalData.AddSystem(sectorKey, parsecKey, id, systemGenerator.Stars);
						globalData.AddGalaxyData(
							x * parsecsPerSector + px,
							y * parsecsPerSector + py,
							z * parsecsPerSector + pz,
							id,
							systemGenerator.Stars
						);
						systemCount++;
					}
					else
					{
						Console.WriteLine("System generation failed - no stars created");
					}
				}
				
				if (processedParsecs % 100 == 0 || processedParsecs == totalParsecs)
				{
					float progress = (float)processedParsecs / totalParsecs;
					Console.WriteLine($"Progress: {progress:P2} ({processedParsecs}/{totalParsecs} parsecs, {systemCount} systems)");
					GenerationProgress?.Invoke(progress, 
						$"Generating parsec {processedParsecs}/{totalParsecs}");
				}
			}
		}

		Console.WriteLine($"Generation complete. Processed {processedParsecs} parsecs, generated {systemCount} systems");
		FinishGeneration();
		GenerationCompleted?.Invoke();
	}

	private void FinishGeneration()
	{
	//	Console.WriteLine($"Systems: {systemCount}, Anomalies: {anomalyCount}");
		Console.WriteLine($"Galaxy generation complete. Total systems: {systemCount}");
		Console.WriteLine($"Galaxy data structure size: {globalData.GalaxyData.Count}");
	}
}

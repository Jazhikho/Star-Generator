using Godot;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Generator;

public class GalaxyGenerator
{
	private GlobalData globalData;
	private int totalParsecs;
	private int systemCount;
	private float progress;
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

	public void GenerateGalaxy(int _x, int _y, int _z, int _parsecs, float _system, float _anomaly, 
		Action<float, string> progressCallback, CancellationToken cancellationToken)
	{
		//GD.Print("Starting galaxy generation");
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
			{
			cancellationToken.ThrowIfCancellationRequested();
			for (int y = 0; y < ySectors; y++)
			for (int z = 0; z < zSectors; z++)
			{
				if (cancellationToken.IsCancellationRequested)
				return;
				string sectorKey = Utils.SetKey(x, y, z);
				
				for (int px = 0; px < parsecsPerSector; px++)
				for (int py = 0; py < parsecsPerSector; py++)
				for (int pz = 0; pz < parsecsPerSector; pz++)
				{
					processedParsecs++;
					
					string parsecKey = Utils.SetKey(px, py, pz);
					string id = $"{sectorKey}-{parsecKey}";
					
					if (random.NextDouble() * 100 < systemChance)
					{
						var systemGenerator = new SystemGenerator();
						if (systemGenerator.Stars.Count > 0)
						{
							globalData.AddSystem(sectorKey, parsecKey, id, systemGenerator.Stars);

							float offsetX = (float)(random.NextDouble() * 0.6 - 0.3);
							float offsetY = (float)(random.NextDouble() * 0.6 - 0.3);
							float offsetZ = (float)(random.NextDouble() * 0.6 - 0.3);

							globalData.AddGalaxyData(
								x * parsecsPerSector + px + offsetX,
								y * parsecsPerSector + py + offsetY,
								z * parsecsPerSector + pz + offsetZ,
								id,
								systemGenerator.Stars
							);
							systemCount++;
						}
					}
				}
				progress = (float)processedParsecs / totalParsecs;
				progressCallback(progress, $"Generating parsec {processedParsecs}/{totalParsecs}");
			}
			progress = (float)processedParsecs / totalParsecs;
			progressCallback(progress, $"Processing data...");
		}
		//GD.Print($"Galaxy generation complete. Total systems: {systemCount}");
	}
}

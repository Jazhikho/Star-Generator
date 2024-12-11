using Godot;
using System;
using System.Collections.Generic;

namespace Generator
{
	public partial class CSBridge : Node
	{
		[Signal]
		public delegate void GenerationProgressEventHandler(float progress, string status);

		[Signal]
		public delegate void GenerationCompletedEventHandler();

		private GalaxyGenerator galaxyGenerator;
		private GlobalData globalData;
		
		public override void _Ready()
		{
			globalData = new GlobalData();
			galaxyGenerator = new GalaxyGenerator(globalData);
		}

		private Dictionary<string, object> GetSettings()
		{
			var settings = new Dictionary<string, object>();
			var globalSettings = GetNode("/root/GlobalSettings");
			
			// Get each setting
			settings["x_sector"] = (int)globalSettings.Call("get_settings", "x_sector", 3);
			settings["y_sector"] = (int)globalSettings.Call("get_settings", "y_sector", 3);
			settings["z_sector"] = (int)globalSettings.Call("get_settings", "z_sector", 3);
			settings["parsecs"] = (int)globalSettings.Call("get_settings", "parsecs", 10);
			settings["system_chance"] = (float)globalSettings.Call("get_settings", "system_chance", 15.0f);
			settings["anomaly_chance"] = (float)globalSettings.Call("get_settings", "anomaly_chance", 1.0f);

			return settings;
		}

		public void GenerateGalaxy(int _x, int _y, int _z, int _parsecs, float _system, float _anomaly)
		{
			galaxyGenerator.GenerationProgress += OnProgressUpdated;
			galaxyGenerator.GenerationCompleted += OnGenerationCompleted;
			galaxyGenerator.GenerateGalaxy(_x, _y, _z, _parsecs, _system, _anomaly);
		}

		private void OnProgressUpdated(float progress, string status)
		{
			EmitSignal(SignalName.GenerationProgress, progress, status);
		}

		private void OnGenerationCompleted()
		{
			EmitSignal(SignalName.GenerationCompleted);
			galaxyGenerator.GenerationProgress += OnProgressUpdated;
			galaxyGenerator.GenerationCompleted += OnGenerationCompleted;
		}
	}
}

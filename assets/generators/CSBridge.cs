using Godot;
using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using System.Text.Json;
using System.Collections.Generic;
using System.Reflection;
using System.Linq;

namespace Generator
{
	public class SaveSlotData
	{
		public string Name { get; set; }
		public DateTime SaveDate { get; set; }
		public GlobalData GalaxyData { get; set; }
	}

	public class SaveFile
	{
		public Dictionary<string, SaveSlotData> SaveSlots { get; set; } = new Dictionary<string, SaveSlotData>();
	}

	public partial class CSBridge : Node
	{
		private CancellationTokenSource cancellationTokenSource;
		private Godot.Timer completionTimer;
		private const double CompletionDelay = 3.0; // 3 seconds
		private GalaxyGenerator galaxyGenerator;
		private static GlobalData _globalData;
		
		private float currentProgress = 0f;
		private string currentStatus = "";
		private bool isGenerating = false;
		private bool isCompleted = false;
		private bool isActuallyComplete = false;

		[Signal]
		public delegate void SaveSlotsRetrievedEventHandler(Godot.Collections.Dictionary slots);

		[Signal]
		public delegate void SaveCompletedEventHandler(bool success);

		[Signal]
		public delegate void LoadCompletedEventHandler(bool success);

		public void CancelGeneration()
		{
			if (isGenerating)
			{
				cancellationTokenSource?.Cancel();
				isGenerating = false;
				isActuallyComplete = true;
				currentStatus = currentStatus;
				completionTimer.Stop();
			}
		}

		public override void _Ready()
		{
			if (_globalData == null)
				_globalData = new GlobalData();
			galaxyGenerator = new GalaxyGenerator(_globalData);
			
			// Setup completion timer
			completionTimer = new Godot.Timer();
			completionTimer.WaitTime = CompletionDelay;
			completionTimer.OneShot = true;
			completionTimer.Timeout += OnCompletionTimeout;
			AddChild(completionTimer);
			
			// GD.Print($"CSBridge initialization complete. Current data size: {_globalData.GalaxyData.Count}");
		}
		
		public void ResetData()
		{
			_globalData.SystemsData.Clear();
			_globalData.GalaxyData.Clear();
		}

		public async void GenerateGalaxy(int _x, int _y, int _z, int _parsecs, float _system, float _anomaly)
		{
			isGenerating = true;
			isCompleted = false;
			isActuallyComplete = false;
			currentProgress = 0f;
			currentStatus = "Starting generation...";
			
			cancellationTokenSource?.Dispose();
			cancellationTokenSource = new CancellationTokenSource();

			void progressHandler(float progress, string status)
			{
				CallDeferred("UpdateProgress", progress, status);
			}

			try
			{
				await Task.Run(() => 
				{
					galaxyGenerator.GenerateGalaxy(_x, _y, _z, _parsecs, _system, _anomaly, 
						progressHandler, cancellationTokenSource.Token);
				});
			}
			catch (OperationCanceledException)
			{
				GD.Print("Galaxy generation was cancelled.");
				// Handle cancellation gracefully
				return;
			}
			finally
			{
				CallDeferred("StartCompletionTimer");
			}
		}

		private void UpdateProgress(float progress, string status)
		{
			currentProgress = progress;
			currentStatus = status;
			
			// Now we're on the main thread, so these calls are safe
			completionTimer.Stop();
			completionTimer.Start();
		}

		private void StartCompletionTimer()
		{
			completionTimer.Start();
		}

		private void OnCompletionTimeout()
		{
			// Only finalize if we're still generating
			if (isGenerating)
			{
				FinalizeGeneration();
			}
		}

		private void FinalizeGeneration()
		{
			currentProgress = 1.0f;
			currentStatus = $"Generation completed! {_globalData.GalaxyData.Count} systems generated.";
			isGenerating = false;
			isActuallyComplete = true;
			
			// Emit any necessary signals or perform any final actions here
		}

		public override void _ExitTree()
		{
			completionTimer?.QueueFree();
			base._ExitTree();
		}

		public float GetCurrentProgress()
		{
			return currentProgress;
		}

		public string GetCurrentStatus()
		{
			return currentStatus;
		}

		public bool IsGenerating()
		{
			return isGenerating;
		}

		public bool IsCompleted()
		{
			return isActuallyComplete;
		}

		public Godot.Collections.Dictionary GetGalaxyDataForSaving()
		{
			var galaxyDataDict = new Godot.Collections.Dictionary();
			foreach (var data in _globalData.GalaxyData)
			{
				galaxyDataDict[data.ID] = new Godot.Collections.Dictionary
				{
					{ "coordinates", new Godot.Vector3(data.Coordinates.X, data.Coordinates.Y, data.Coordinates.Z) },
					{ "id", data.ID },
					{ "systemStars", data.SystemStars },
					{ "luminosity", data.Luminosity },
					{ "temperature", data.Temperature }
				};
			}
			return galaxyDataDict;
		}

		// Method to convert systems data to a Godot Dictionary for saving
		public Godot.Collections.Dictionary GetSystemsDataForSaving()
		{
			var systemsDataDict = new Godot.Collections.Dictionary();
			
			GD.Print($"SystemsData count: {_globalData.SystemsData?.Count ?? 0}");
			
			if (_globalData.SystemsData == null)
			{
				GD.Print("_globalData.SystemsData is null");
				return systemsDataDict;
			}

			try
			{
				foreach (var data in _globalData.SystemsData)
				{
					GD.Print($"Processing system with ID: {data?.ID ?? "null"}");
					GD.Print($"Data type: {data?.Data?.GetType()?.FullName ?? "null"}");

					var starDataList = data.Data as List<StarData>;
					if (starDataList == null)
					{
						GD.Print($"Failed to cast Data to List<StarData>. Actual type: {data?.Data?.GetType()?.FullName ?? "null"}");
						continue;
					}

					var godotStarDataList = new Godot.Collections.Array();
					foreach (var starData in starDataList)
					{
						if (starData == null)
						{
							GD.Print("starData is null");
							continue;
						}
						try
						{
							var convertedData = ConvertToGodotDictionary(starData);
							godotStarDataList.Add(convertedData);
						}
						catch (Exception e)
						{
							GD.PrintErr($"Error converting star data: {e.Message}");
							continue;
						}
					}

					try
					{
						systemsDataDict[data.ID] = new Godot.Collections.Dictionary
						{
							{ "type", data.Type },
							{ "sectorKey", data.SectorKey },
							{ "parsecKey", data.ParsecKey },
							{ "id", data.ID },
							{ "data", godotStarDataList }
						};
					}
					catch (Exception e)
					{
						GD.PrintErr($"Error creating system dictionary: {e.Message}");
						continue;
					}
				}
			}
			catch (Exception e)
			{
				GD.PrintErr($"Major error in GetSystemsDataForSaving: {e.Message}\n{e.StackTrace}");
				return new Godot.Collections.Dictionary();
			}

			GD.Print($"Final systemsDataDict count: {systemsDataDict.Count}");
			return systemsDataDict;
		}

		// Method to convert an object to a Godot Dictionary
		private Godot.Collections.Dictionary ConvertToGodotDictionary(object obj)
		{
			var dict = new Godot.Collections.Dictionary();

			try
			{
				// Handle properties
				foreach (var prop in obj.GetType().GetProperties())
				{
					var value = prop.GetValue(obj);
					if (value != null)
					{
						GD.Print($"Converting property: {prop.Name}, Type: {value.GetType().FullName}");
						
						if (prop.Name == "CelestialBodies" || prop.Name == "Satellites")
						{
							var celestialBodiesList = new Godot.Collections.Array();
							var bodyList = (System.Collections.IList)value;
							foreach (var body in bodyList)
							{
								celestialBodiesList.Add(ConvertCelestialBody(body));
							}
							dict[prop.Name] = celestialBodiesList;
						}
						else if (prop.Name == "OrbitalLimits")
						{
							dict[prop.Name] = ConvertToGodotDictionary(value);
						}
						else
						{
							dict[prop.Name] = ConvertValue(value);
						}
					}
				}

				// Handle fields (for structs)
				foreach (var field in obj.GetType().GetFields())
				{
					var value = field.GetValue(obj);
					if (value != null)
					{
						GD.Print($"Converting field: {field.Name}, Type: {value.GetType().FullName}");
						
						if (field.Name == "Satellites")
						{
							var satellitesList = new Godot.Collections.Array();
							foreach (var satellite in (List<object>)value)
							{
								satellitesList.Add(ConvertCelestialBody(satellite));
							}
							dict[field.Name] = satellitesList;
						}
						else if (field.Name == "SignificantBodies")
						{
							var significantBodiesList = new Godot.Collections.Array();
							foreach (var significantBody in (List<string>)value)
							{
								significantBodiesList.Add(significantBody);
							}
							dict[field.Name] = significantBodiesList;
						}
						else
						{
							dict[field.Name] = ConvertValue(value);
						}
					}
				}
			}
			catch (Exception e)
			{
				GD.PrintErr($"Error in ConvertToGodotDictionary: {e.Message}");
			}

			return dict;
		}

		// Method to convert a celestial body to a Godot Dictionary
		private Godot.Collections.Dictionary ConvertCelestialBody(object body)
		{
			var dict = new Godot.Collections.Dictionary();

			try
			{
				var bodyType = body.GetType();
				GD.Print($"Converting celestial body of type: {bodyType.FullName}");

				// Special handling for ring system list
				if (bodyType.IsGenericType && bodyType.GetGenericTypeDefinition() == typeof(List<>))
				{
					var list = (System.Collections.IList)body;
					if (list.Count > 0 && list[0] is string ringType && (ringType == "Simple" || ringType == "Complex"))
					{
						// This is a ring system
						var ringDict = new Godot.Collections.Dictionary
						{
							{ "Type", "Rings" },
							{ "RingType", ringType }
						};

						if (ringType == "Simple" && list.Count == 2)
						{
							ringDict["Orbit"] = ConvertValue(list[1]);
						}
						else if (ringType == "Complex" && list.Count == 3)
						{
							ringDict["InnerOrbit"] = ConvertValue(list[1]);
							ringDict["OuterOrbit"] = ConvertValue(list[2]);
						}

						return ringDict;
					}
					else
					{
						// Handle other lists as before
						var godotList = new Godot.Collections.Array();
						foreach (var item in list)
						{
							godotList.Add(ConvertCelestialBody(item));
						}
						return new Godot.Collections.Dictionary { { "NestedList", godotList } };
					}
				}

				// Handle string type (but not as a celestial body)
				if (bodyType == typeof(string))
				{
					return new Godot.Collections.Dictionary { { "Value", body as string } };
				}

				// Handle PlanetaryData type
				if (bodyType == typeof(PlanetaryData))
				{
					dict["Type"] = "Planet";
					foreach (var field in bodyType.GetFields())
					{
						var value = field.GetValue(body);
						if (value != null)
						{
							// Special handling for Satellites
							if (field.Name == "Satellites")
							{
								var satellitesList = new Godot.Collections.Array();
								var list = (List<object>)value;
								string rings = null;
								
								GD.Print($"  Satellites count: {list.Count}");
								for (int i = 0; i < list.Count; i++)
								{
									var item = list[i];
									GD.Print($"    Satellite {i} type: {item?.GetType()?.FullName ?? "null"}");
									
									// Check for rings (string type)
									if (item is string stringItem)
									{
										GD.Print($"      Found rings: '{stringItem}'");
										rings = stringItem;
										continue;  // Skip adding this to the satellites list
									}
									
									// Add other items as satellites
									satellitesList.Add(ConvertCelestialBody(item));
								}
								
								// Add satellites and rings separately
								dict[field.Name] = satellitesList;
								if (rings != null)
								{
									dict["Rings"] = rings;
								}
							}
							else
							{
								dict[field.Name] = ConvertValue(value);
							}
						}
					}
				}
				// Handle SmallBodyGroup.BodyData type (Asteroid Belt)
				else if (bodyType == typeof(SmallBodyGroup.BodyData))
				{
					GD.Print("  Processing Asteroid Belt data:");
					dict["Type"] = "AsteroidBelt";
					foreach (var prop in bodyType.GetProperties())
					{
						GD.Print($"    Property: {prop.Name}");
						var value = prop.GetValue(body);
						if (value != null)
						{
							// Special handling for SignificantBodies
							GD.Print($"      Value type: {value.GetType().FullName}");
							
							if (prop.Name == "SignificantBodies")
							{
								var significantBodiesList = new Godot.Collections.Array();
								var list = (System.Collections.IList)value;
								GD.Print($"      SignificantBodies count: {list.Count}");
								for (int i = 0; i < list.Count; i++)
								{
									GD.Print($"        Item {i} type: {list[i]?.GetType()?.FullName ?? "null"}");
									significantBodiesList.Add(ConvertCelestialBody(list[i]));
								}
								dict[prop.Name] = significantBodiesList;
							}
							else
							{
								dict[prop.Name] = ConvertValue(value);
							}
						}
					}
				}
				// Handle other unknown types by converting all their properties/fields
				else
				{
					GD.Print($"  Handling unknown type: {bodyType.FullName}");
					
					// Try properties first
					foreach (var prop in bodyType.GetProperties())
					{
						var value = prop.GetValue(body);
						if (value != null)
						{
							dict[prop.Name] = ConvertValue(value);
						}
					}
					
					// Then try fields
					foreach (var field in bodyType.GetFields())
					{
						var value = field.GetValue(body);
						if (value != null)
						{
							dict[field.Name] = ConvertValue(value);
						}
					}
				}
			}
			catch (Exception e)
			{
				GD.PrintErr($"Error converting celestial body: {e.Message}");
				if (body is string strValue)
				{
					GD.PrintErr($"Failed string value was: '{strValue}'");
				}
				GD.PrintErr($"Stack trace: {e.StackTrace}");
			}

			return dict;
		}

		// Method to convert a value to a Godot Variant
		private Variant ConvertValue(object value)
		{
		try
		{
			switch (value)
			{
				case null:
					return new Variant();
				case string s:
					return s;
				case bool b:
					return b;
				case float f:
					return (double)f;
				case int i:
					return (long)i;
				case Dictionary<string, int> dictInt:
					var godotDictInt = new Godot.Collections.Dictionary();
					foreach (var kvp in dictInt)
						godotDictInt[kvp.Key] = (long)kvp.Value;
					return godotDictInt;
				case Dictionary<string, float> dictFloat:
					var godotDictFloat = new Godot.Collections.Dictionary();
					foreach (var kvp in dictFloat)
						godotDictFloat[kvp.Key] = (double)kvp.Value;
					return godotDictFloat;
				case Dictionary<string, object> dictObj:
					var godotDictObj = new Godot.Collections.Dictionary();
					foreach (var kvp in dictObj)
						godotDictObj[kvp.Key] = ConvertValue(kvp.Value);
					return godotDictObj;
				default:
					// For complex types, try to convert their properties
					var type = value.GetType();
					GD.Print($"  Attempting to convert complex type: {type.FullName}");
					
					var complexDict = new Godot.Collections.Dictionary();
					foreach (var prop in type.GetProperties())
					{
						var propValue = prop.GetValue(value);
						complexDict[prop.Name] = ConvertValue(propValue);
					}
					foreach (var field in type.GetFields())
					{
						var fieldValue = field.GetValue(value);
						complexDict[field.Name] = ConvertValue(fieldValue);
					}
					return complexDict;
			}
		}
		catch (Exception e)
		{
			GD.PrintErr($"Error in ConvertValue for type {value?.GetType()?.FullName ?? "null"}: {e.Message}\n{e.StackTrace}");
			return new Variant();
		}
	}

		public void LoadSavedData(Godot.Collections.Dictionary galaxyData, Godot.Collections.Dictionary systemsData)
		{
			GD.Print($"Loading data. Galaxy data count: {galaxyData.Count}, Systems data count: {systemsData.Count}");
			
			_globalData.ResetData();
			
			try
			{
				foreach (var entry in galaxyData)
				{
					var data = (Godot.Collections.Dictionary)entry.Value;
					var coords = (Godot.Vector3)data["coordinates"];
					_globalData.AddGalaxyData(
						coords.X,
						coords.Y,
						coords.Z,
						(string)data["id"],
						new List<StarData>() // You might need to adjust this
					);
				}
				
				foreach (var entry in systemsData)
				{
					var data = (Godot.Collections.Dictionary)entry.Value;
					var godotStarDataList = (Godot.Collections.Array)data["data"];
					var starDataList = new List<StarData>();
					foreach (Godot.Collections.Dictionary starDict in godotStarDataList)
					{
						starDataList.Add(new StarData
						{
							Luminosity = (float)starDict["luminosity"],
							Temperature = (float)starDict["temperature"]
						});
					}

					_globalData.AddSystem(
						(string)data["sectorKey"],
						(string)data["parsecKey"],
						(string)data["id"],
						starDataList
					);
				}
				
				GD.Print($"Finished loading. Current data size: {_globalData.GalaxyData.Count}");
			}
			catch (Exception e)
			{
				GD.PrintErr($"Error loading saved data: {e.Message}");
			}
		}
		
		public Godot.Collections.Dictionary GetStarDataForRendering()
		{
			var starDataForRendering = new Godot.Collections.Dictionary();
			
			foreach (var galaxyData in _globalData.GalaxyData)
			{
				var starInfo = new Godot.Collections.Dictionary
				{
					{ "coordinates", new Vector3(galaxyData.Coordinates.X, galaxyData.Coordinates.Y, galaxyData.Coordinates.Z) },
					{ "luminosity", galaxyData.Luminosity },
					{ "temperature", galaxyData.Temperature },
					{ "id", galaxyData.ID },
					{ "systemStars", galaxyData.SystemStars }
				};
				starDataForRendering[galaxyData.ID] = starInfo;
			}
			return starDataForRendering;
		}

		public int GetSystemCount()
		{
			return _globalData?.GalaxyData?.Count ?? 0;
		}
	}
}

using Godot;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;

public class DataLoader
{
	private readonly string _filePath;

	public DataLoader()
	{
		string basePath = ProjectSettings.GlobalizePath("res://");
		_filePath = Path.Combine(basePath, "assets", "generators", "stellar_data.json");
}

	public Dictionary<string, object> LoadStellarData(string dataType)
	{
		try
		{
			if (!File.Exists(_filePath))
			{
				GD.PrintErr($"File not found: {_filePath}");
				return null;
			}

			string jsonString = File.ReadAllText(_filePath);

			using JsonDocument document = JsonDocument.Parse(jsonString);
			JsonElement root = document.RootElement;

			if (root.TryGetProperty(dataType, out JsonElement typeData))
			{
				var result = ConvertJsonElementToDictionary(typeData);
				GD.Print($"Successfully loaded data for '{dataType}'. Entries: {result.Count}");
				return result;
			}
			else
			{
				GD.PrintErr($"Data type '{dataType}' not found in JSON.");
				return null;
			}
		}
		catch (Exception ex)
		{
			GD.PrintErr($"Error loading data: {ex.Message}");
			return null;
		}
	}

	private Dictionary<string, object> ConvertJsonElementToDictionary(JsonElement element)
	{
		var result = new Dictionary<string, object>();

		if (element.ValueKind == JsonValueKind.Object)
		{
			foreach (JsonProperty property in element.EnumerateObject())
			{
				result[property.Name] = ConvertJsonElement(property.Value);
			}
		}

		return result;
	}

	private object ConvertJsonElement(JsonElement element)
	{
		switch (element.ValueKind)
		{
			case JsonValueKind.Object:
				return ConvertJsonElementToDictionary(element);
			case JsonValueKind.Array:
				var list = new List<object>();
				foreach (JsonElement item in element.EnumerateArray())
				{
					list.Add(ConvertJsonElement(item));
				}
				return list;
			case JsonValueKind.String:
				return element.GetString();
			case JsonValueKind.Number:
				if (element.TryGetInt32(out int intValue))
					return intValue;
				if (element.TryGetSingle(out float floatValue))
					return floatValue;
				if (element.TryGetDouble(out double doubleValue))
					return doubleValue;
				throw new ArgumentException($"Unable to determine number type for {element}");
			case JsonValueKind.True:
				return true;
			case JsonValueKind.False:
				return false;
			case JsonValueKind.Null:
				return null;
		}

		throw new ArgumentException($"Unexpected JSON value kind: {element.ValueKind}");
	}
}

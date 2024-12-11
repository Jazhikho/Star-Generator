using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using Generator;
using StellarLibraries;

public class SmallBody
{
	private static readonly Dictionary<string, Dictionary<string, object>> COMPOSITIONS = new()
	{
		{"A", new Dictionary<string, object> {{"name", "Siliceous"}, {"density", 3.73f}, {"albedo", new Vector2(0.13f, 0.35f)}}},
		{"B", new Dictionary<string, object> {{"name", "Carbonaceous"}, {"density", 2.38f}, {"albedo", new Vector2(0.04f, 0.08f)}}},
		{"C", new Dictionary<string, object> {{"name", "Carbonaceous"}, {"density", 1.33f}, {"albedo", new Vector2(0.03f, 0.09f)}}},
		{"D", new Dictionary<string, object> {{"name", "Carbonaceous"}, {"density", 1f}, {"albedo", new Vector2(0.02f, 0.05f)}}},
		{"E", new Dictionary<string, object> {{"name", "Metallic"}, {"density", 2.67f}, {"albedo", new Vector2(0.25f, 0.6f)}}},
		{"F", new Dictionary<string, object> {{"name", "Carbonaceous"}, {"density", 2.38f}, {"albedo", new Vector2(0.03f, 0.07f)}}},
		{"G", new Dictionary<string, object> {{"name", "Carbonaceous"}, {"density", 2.1f}, {"albedo", new Vector2(0.05f, 0.09f)}}},
		{"K", new Dictionary<string, object> {{"name", "Siliceous"}, {"density", 3.54f}, {"albedo", new Vector2(0.1f, 0.14f)}}},
		{"L", new Dictionary<string, object> {{"name", "Siliceous"}, {"density", 2.38f}, {"albedo", new Vector2(0.13f, 0.35f)}}},
		{"M", new Dictionary<string, object> {{"name", "Metallic"}, {"density", 3.49f}, {"albedo", new Vector2(0.1f, 0.18f)}}},
		{"P", new Dictionary<string, object> {{"name", "Metallic"}, {"density", 2.84f}, {"albedo", new Vector2(0.02f, 0.06f)}}},
		{"Q", new Dictionary<string, object> {{"name", "Siliceous"}, {"density", 2.72f}, {"albedo", new Vector2(0.18f, 0.24f)}}},
		{"R", new Dictionary<string, object> {{"name", "Siliceous"}, {"density", 2.23f}, {"albedo", new Vector2(0.05f, 0.09f)}}},
		{"S", new Dictionary<string, object> {{"name", "Siliceous"}, {"density", 2.72f}, {"albedo", new Vector2(0.1f, 0.28f)}}},
		{"T", new Dictionary<string, object> {{"name", "Carbonaceous"}, {"density", 2.61f}, {"albedo", new Vector2(0.04f, 0.11f)}}},
		{"V", new Dictionary<string, object> {{"name", "Siliceous"}, {"density", 1.63f}, {"albedo", new Vector2(0.22f, 0.48f)}}},
	};

	public string BodyType { get; private set; }
	public float Diameter { get; private set; }
	public Dictionary<string, object> Composition { get; private set; }
	public float Density { get; private set; }
	public float Albedo { get; private set; }
	public float Mass { get; private set; }
	public Dictionary<string, object> Data { get; private set; }

	public SmallBody(string smallbodyType, float size)
	{
		BodyType = smallbodyType;
		Diameter = size;
		Composition = GetComposition();
		Density = CalculateDensity();
		Albedo = CalculateAlbedo();
		Mass = CalculateMass();
		Data = new Dictionary<string, object>
		{
			{"type", BodyType},
			{"diameter", Diameter},
			{"composition", Composition},
			{"density", Density},
			{"albedo", Albedo},
			{"mass", Mass},
			{"rotation_period", CalculateRotationPeriod()},
			{"desirability", CalculateDesirability()}
		};
	}

	private Dictionary<string, object> GetComposition()
	{
		return BodyType switch
		{
			"Short_Period_Comet" or "Long_Period_Comet" => new Dictionary<string, object>(),
			_ => COMPOSITIONS.GetValueOrDefault(BodyType, new Dictionary<string, object>())
		};
	}

	private float CalculateDensity()
	{
		// Implement density calculation logic here
		return Composition.ContainsKey("density") ? Convert.ToSingle(Composition["density"]) : 0.0f;
	}

	private float CalculateAlbedo()
	{
		if (Composition.ContainsKey("albedo"))
		{
			var albedoRange = (Vector2)Composition["albedo"];
			return (float)GD.RandRange(albedoRange.X, albedoRange.Y);
		}
		return 0.0f;
	}

	private float CalculateMass()
	{
		return Diameter / 1000 * Density;
	}

	private float CalculateRotationPeriod()
	{
		return (float)GD.RandRange(2, 24);
	}

	private int CalculateDesirability()
	{
	if (BodyType == "Short_Period_Comet" || BodyType == "Long_Period_Comet")
		return -5;
	
	return DesirabilityCalculator.CalculateResourceValue(true);
	}

	public partial class Asteroid : SmallBody
	{
		public Asteroid(float size) : base("Asteroid", size) { }
	}

	public partial class ShortPeriodComet : SmallBody
	{
		public ShortPeriodComet(float size) : base("Short_Period_Comet", size) { }
	}

	public partial class LongPeriodComet : SmallBody
	{
		public LongPeriodComet(float size) : base("Long_Period_Comet", size) { }
	}
}

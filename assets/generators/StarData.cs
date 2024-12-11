using Godot;
using System;
using System.Collections.Generic;
using System.Numerics;

namespace Generator
{
	public class StarData
	{
		public int StarId { get; set; }
		public float Mass { get; set; }
		public float? CombinedMass { get; set; }
		public float Age { get; set; }
		public string SpectralType { get; set; }
		public int LuminosityClass { get; set; }
		public float Luminosity { get; set; }
		public float Temperature { get; set; }
		public float Radius { get; set; }
		public bool IsFlareStar { get; set; }
		public List<object> CelestialBodies { get; set; }
		public float? HierarchicalSeparation { get; set; }
		public float HierarchicalEccentricity { get; set; }
		public float HierarchicalMinSeparation { get; set; }
		public float HierarchicalMaxSeparation { get; set; }
		public float HierarchicalOrbitalPeriod { get; set; }
		public float? Separation { get; set; }
		public float Eccentricity { get; set; }
		public float? MinSeparation { get; set; }
		public float? MaxSeparation { get; set; }
		public float OrbitalPeriod { get; set; }
		public OrbitalLimitsData OrbitalLimits { get; set; }
	}

	public class OrbitalLimitsData
	{
		public float Inner { get; set; }
		public float Outer { get; set; }
		public float SnowLine { get; set; }
	}
	
	public struct OrbitalData
	{
		public float Eccentricity;
		public float OrbitalPeriod;
		public float AxialTilt;
	}

	public struct SatelliteLimits
	{
		public OrbitalRange MajorMoons;
		public OrbitalRange Moonlets;
	}

	public struct OrbitalRange
	{
		public float Start;
		public float End;
	}

	public struct RingLimits
	{
		public float Inner;
		public float Outer;
	}

	public struct MoonData
	{
		public int Count;
		public string Type;
		public int Mod;
	}

	public struct SeparationData
	{
		public string Category;
		public float Multiplier;
	}
	
	public struct BiochemistryData
	{
		public string Biosphere;
		public string Chemistry;
	}
	
	public struct BrownDwarfData
	{
		public float Luminosity;
		public float Temperature;
		public float Radius;
		public string SpectralType;
	}

	public struct ClimateData
	{
		public float Blackbody;
		public float Temperature;
		public string Climate;
		public float Absorption;
	}

	public struct MassiveStarData
	{
		public float Age;
		public float Luminosity;
		public float Temperature;
		public float Radius;
		public string SpectralType;
	}
	
	public struct PlanetBasicsData
	{
		public int Size;
		public string SizeCategory;
		public float Density;
		public float Diameter;
		public float Mass;
		public float Gravity;
	}
	
	public struct PlanetaryData
	{
		public string SpectralType;
		public int LuminosityClass;
		public float Age;
		public float StarMass;
		public string PlanetClass;
		public float Orbit;
		public string Zone;
		public float ParentMass;
		public int Size;
		public string SizeCategory;
		public float Density;
		public float Diameter;
		public float Mass;
		public float Gravity;
		public float Eccentricity;
		public float OrbitalPeriod;
		public float AxialTilt;
		public float Atmosphere;
		public float AtmoMass;
		public string AtmoComposition;
		public float Hydrology;
		public string Biosphere;
		public string Chemistry;
		public float Blackbody;
		public float Temperature;
		public string Climate;
		public float Absorption;
		public List<object> Satellites;
		public float RotationalPeriod;
		public float DayLength;
		public string PlanetType;
		public string VolcanicActivity;
		public string TectonicActivity;
	}
	
	public struct AtmosphereData
	{
		public int Atmosphere;
		public float AtmoMass;
		public string AtmoComposition;
	}

	public struct TidalLockData
	{
		public int Atmosphere;
		public float Hydrology;
		public Temperature Temperature;
	}

	public struct Temperature
	{
		public float Day;
		public float Night;
	}
}

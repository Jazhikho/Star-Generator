using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using Generator;
using StellarLibraries;

public class SystemArrangement
{
	private const float STAR_COUNT_FACTOR = 0.5f;

	private List<StarData> stars;
	private OrbitalLimits orbitalLimits;

	public int DetermineStarCount()
	{
		return Roll.Dice(6, 4, -15, 1, 10);
	}

	public float GetEffectiveMass(StarData star)
	{
		return star.CombinedMass ?? star.Mass;
	}

	public List<StarData> ArrangeStars(List<StarData> _stars, OrbitalLimits _orbitalLimits)
	{
		orbitalLimits = _orbitalLimits;
		stars = _stars;

		if (stars.Count == 0) return stars;

		var primaryStar = stars[0];
		primaryStar.OrbitalLimits = orbitalLimits.CalculateOrbitalLimits(primaryStar);
		stars[0] = primaryStar;

		if (stars.Count == 1) return stars;

		int starCount = stars.Count;
		int pairingRounds = (int)Math.Ceiling(Math.Log(starCount, 2));

		for (int pairingRound = 0; pairingRound < pairingRounds; pairingRound++)
		{
			int stride = (int)Math.Pow(2, pairingRound);
			for (int i = 0; i < starCount; i += stride * 2)
			{
				int primaryIndex = i;
				int secondaryIndex = i + stride;

				if (secondaryIndex < starCount)
				{
					PairStars(stars[primaryIndex], stars[secondaryIndex], pairingRound);
				}
			}
		}

		return stars;
	}

	private void PairStars(StarData primary, StarData secondary, int pairingRound)
	{
		var starOrbits = new OrbitalDynamics();
		float primaryMass = GetEffectiveMass(primary);
		float secondaryMass = GetEffectiveMass(secondary);

		// For the first pairing round, we use the star's own separation (if any)
		// For subsequent rounds, we use the separation determined in previous rounds
		float minSeparation = pairingRound == 0
			? (primary.Separation ?? 0f)
			: (secondary.HierarchicalSeparation ?? 0f);

		float separationData = starOrbits.DetermineSeparation(pairingRound, minSeparation);

		// Store the hierarchical separation separately
		secondary.HierarchicalSeparation = separationData;
		secondary.HierarchicalEccentricity = starOrbits.CalculateEccentricity();
		secondary.HierarchicalMinSeparation = (1 - secondary.HierarchicalEccentricity) * separationData;
		secondary.HierarchicalMaxSeparation = (1 + secondary.HierarchicalEccentricity) * separationData;
		secondary.HierarchicalOrbitalPeriod = starOrbits.CalculateOrbitalPeriod(
			separationData, primaryMass, secondaryMass, true
		);

		if (pairingRound == 0)
		{
			// First round: calculate orbital limits for both stars
			primary.OrbitalLimits = orbitalLimits.CalculateOrbitalLimits(primary, separationData);
			secondary.OrbitalLimits = separationData <= 15
				? new OrbitalLimitsData { Inner = 0, Outer = 0, SnowLine = 0 }
				: orbitalLimits.CalculateOrbitalLimits(secondary, separationData);
		}
		else
		{
			// Subsequent rounds: only recalculate for the secondary
			secondary.OrbitalLimits = orbitalLimits.CalculateOrbitalLimits(secondary, separationData);
		}
		primary.CombinedMass = primaryMass + secondaryMass;
	}
}

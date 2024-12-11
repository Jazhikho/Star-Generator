using Godot;
using System;
using System.Collections.Generic;

namespace StellarLibraries
{
	public static class StarsData
	{
		public static Dictionary<string, object> BROWN_DWARF = new Dictionary<string, object>
		{
			["MASS"] = new Dictionary<string, int>
			{
				["0.01"] = 8,
				["0.02"] = 10,
				["0.03"] = 12,
				["0.04"] = 14,
				["0.05"] = 15,
				["0.06"] = 16,
				["0.07"] = 18
			},
			["PARAMETERS"] = new Dictionary<string, Dictionary<string, double>>
			{
				["0.01"] = new Dictionary<string, double>
				{
					["Luminosity"] = 0.0073,
					["Radius"] = 0.08021949
				},
				["0.02"] = new Dictionary<string, double>
				{
					["Luminosity"] = 0.0016,
					["Radius"] = 0.0770107
				},
				["0.03"] = new Dictionary<string, double>
				{
					["Luminosity"] = 0.0045,
					["Radius"] = 0.07288514
				},
				["0.04"] = new Dictionary<string, double>
				{
					["Luminosity"] = 0.0097,
					["Radius"] = 0.07013475
				},
				["0.05"] = new Dictionary<string, double>
				{
					["Luminosity"] = 0.017,
					["Radius"] = 0.0678428
				},
				["0.06"] = new Dictionary<string, double>
				{
					["Luminosity"] = 0.028,
					["Radius"] = 0.06646758
				},
				["0.07"] = new Dictionary<string, double>
				{
					["Luminosity"] = 0.042,
					["Radius"] = 0.0650924
				}
			},
			["TEMPS"] = new Dictionary<string, int>
			{
				["250"] = 2,
				["445"] = 3,
				["640"] = 4,
				["835"] = 5,
				["1030"] = 6,
				["1225"] = 7,
				["1420"] = 8,
				["1615"] = 9,
				["1810"] = 10,
				["2005"] = 11,
				["2200"] = 12
			},
			["CLASS"] = new Dictionary<string, int>
			{
				["Y"] = 640,
				["T"] = 1125,
				["L"] = 2200
			},
			["MULTIPLIERS"] = new Dictionary<string, Dictionary<string, int>>
			{
				["LUMINOSITY"] = new Dictionary<string, int>
				{
					["1"] = 1,
					["0.41"] = 2,
					["0.24"] = 3,
					["0.16"] = 4,
					["0.12"] = 5,
					["0.097"] = 6,
					["0.080"] = 7,
					["0.067"] = 8,
					["0.057"] = 9,
					["0.050"] = 10,
					["0.044"] = 11,
					["0.040"] = 12,
					["0.036"] = 13,
					["0.032"] = 14
				},
				["RADIUS"] = new Dictionary<string, int>
				{
					["1.0"] = 1,
					["0.96"] = 2,
					["0.94"] = 3,
					["0.93"] = 4,
					["0.91"] = 5,
					["0.90"] = 7,
					["0.89"] = 8,
					["0.88"] = 10,
					["0.87"] = 13,
					["0.86"] = 18
				}
			}
		};

		public static Dictionary<string, Dictionary<string, int>> STELLAR_MASS = new Dictionary<string, Dictionary<string, int>>
		{
			["3"] = new Dictionary<string, int>
			{
				["2"] = 10,
				["1.9"] = 18
			},
			["4"] = new Dictionary<string, int>
			{
				["1.8"] = 8,
				["1.7"] = 11,
				["1.6"] = 18
			},
			["5"] = new Dictionary<string, int>
			{
				["1.5"] = 7,
				["1.45"] = 10,
				["1.4"] = 12,
				["1.35"] = 18
			},
			["6"] = new Dictionary<string, int>
			{
				["1.3"] = 7,
				["1.25"] = 9,
				["1.2"] = 10,
				["1.15"] = 12,
				["1.1"] = 18
			},
			["7"] = new Dictionary<string, int>
			{
				["1"] = 9,
				["1.05"] = 7,
				["0.95"] = 10,
				["0.9"] = 12,
				["0.85"] = 18
			},
			["8"] = new Dictionary<string, int>
			{
				["0.8"] = 7,
				["0.75"] = 9,
				["0.7"] = 10,
				["0.65"] = 12,
				["0.6"] = 18
			},
			["9"] = new Dictionary<string, int>
			{
				["0.55"] = 8,
				["0.5"] = 11,
				["0.45"] = 18
			},
			["10"] = new Dictionary<string, int>
			{
				["0.4"] = 8,
				["0.35"] = 11,
				["0.3"] = 18
			},
			["11"] = new Dictionary<string, int>
			{
				["0.25"] = 18
			},
			["12"] = new Dictionary<string, int>
			{
				["0.2"] = 18
			},
			["13"] = new Dictionary<string, int>
			{
				["0.15"] = 18
			},
			["14"] = new Dictionary<string, int>
			{
				["0.1"] = 18
			}
		};

		public static Dictionary<string, double[]> STELLAR_AGE = new Dictionary<string, double[]>
		{
			["3"] = new double[] { 0, 0, 0 },
			["6"] = new double[] { 0.1, 0.3, 0.05 },
			["10"] = new double[] { 2, 0.6, 0.1 },
			["14"] = new double[] { 5.6, 0.6, 0.1 },
			["17"] = new double[] { 8, 0.6, 0.1 },
			["18"] = new double[] { 10, 0.6, 0.1 }
		};

		public static Dictionary<string, int> STELLAR_VAR = new Dictionary<string, int>
		{
			["0.08"] = 89,
			["0.1"] = 124,
			["0.15"] = 174,
			["0.2"] = 224,
			["0.25"] = 274,
			["0.3"] = 324,
			["0.35"] = 374,
			["0.4"] = 424,
			["0.45"] = 474,
			["0.5"] = 524,
			["0.55"] = 574,
			["0.6"] = 624,
			["0.65"] = 674,
			["0.7"] = 724,
			["0.75"] = 774,
			["0.8"] = 824,
			["0.85"] = 874,
			["0.9"] = 924,
			["0.95"] = 974,
			["1.0"] = 1024,
			["1.05"] = 1074,
			["1.1"] = 1124,
			["1.15"] = 1174,
			["1.2"] = 1224,
			["1.25"] = 1274,
			["1.3"] = 1324,
			["1.35"] = 1374,
			["1.4"] = 1424,
			["1.45"] = 1474,
			["1.5"] = 1524,
			["1.55"] = 1574,
			["1.6"] = 1624,
			["1.65"] = 1674,
			["1.7"] = 1724,
			["1.75"] = 1774,
			["1.8"] = 1824,
			["1.85"] = 1874,
			["1.9"] = 1924,
			["1.95"] = 1974,
			["2.0"] = 2499,
			["3"] = 3249,
			["3.5"] = 3749,
			["4"] = 4249,
			["4.5"] = 4749,
			["5"] = 5249,
			["5.5"] = 5749,
			["6"] = 6749,
			["7.5"] = 7749,
			["8"] = 8499,
			["9"] = 9499,
			["10"] = 10999,
			["12"] = 13749,
			["15"] = 17499,
			["20"] = 20999,
			["22"] = 23749,
			["25"] = 26749,
			["28"] = 28999,
			["30"] = 32499,
			["35"] = 37499,
			["40"] = 42499,
			["45"] = 47499,
			["50"] = 54999,
			["60"] = 64999,
			["70"] = 74999,
			["80"] = 84999,
			["90"] = 94999,
			["100"] = 100000
		};

		public static Dictionary<string, Dictionary<string, object>> STELLAR_EVOLUTION = new Dictionary<string, Dictionary<string, object>>
		{
			["0.08"] = new Dictionary<string, object>
			{
				["Type"] = "M8",
				["Temperature"] = 3000,
				["L-Min"] = 0.001
			},
			["0.1"] = new Dictionary<string, object>
			{
				["Type"] = "M7",
				["Temperature"] = 3100,
				["L-Min"] = 0.0012
			},
			["0.15"] = new Dictionary<string, object>
			{
				["Type"] = "M6",
				["Temperature"] = 3200,
				["L-Min"] = 0.0036
			},
			["0.2"] = new Dictionary<string, object>
			{
				["Type"] = "M5",
				["Temperature"] = 3200,
				["L-Min"] = 0.0079
			},
			["0.25"] = new Dictionary<string, object>
			{
				["Type"] = "M4",
				["Temperature"] = 3300,
				["L-Min"] = 0.015
			},
			["0.3"] = new Dictionary<string, object>
			{
				["Type"] = "M4",
				["Temperature"] = 3300,
				["L-Min"] = 0.024
			},
			["0.35"] = new Dictionary<string, object>
			{
				["Type"] = "M3",
				["Temperature"] = 3400,
				["L-Min"] = 0.037
			},
			["0.4"] = new Dictionary<string, object>
			{
				["Type"] = "M2",
				["Temperature"] = 3500,
				["L-Min"] = 0.054
			},
			["0.45"] = new Dictionary<string, object>
			{
				["Type"] = "M1",
				["Temperature"] = 3600,
				["L-Min"] = 0.07,
				["L-Max"] = 0.08,
				["M-Span"] = 70
			},
			["0.5"] = new Dictionary<string, object>
			{
				["Type"] = "M0",
				["Temperature"] = 3800,
				["L-Min"] = 0.09,
				["L-Max"] = 0.11,
				["M-Span"] = 59
			},
			["0.55"] = new Dictionary<string, object>
			{
				["Type"] = "K8",
				["Temperature"] = 4000,
				["L-Min"] = 0.11,
				["L-Max"] = 0.15,
				["M-Span"] = 50
			},
			["0.6"] = new Dictionary<string, object>
			{
				["Type"] = "K6",
				["Temperature"] = 4200,
				["L-Min"] = 0.13,
				["L-Max"] = 0.2,
				["M-Span"] = 42
			},
			["0.65"] = new Dictionary<string, object>
			{
				["Type"] = "K5",
				["Temperature"] = 4400,
				["L-Min"] = 0.15,
				["L-Max"] = 0.25,
				["M-Span"] = 37
			},
			["0.7"] = new Dictionary<string, object>
			{
				["Type"] = "K4",
				["Temperature"] = 4600,
				["L-Min"] = 0.19,
				["L-Max"] = 0.35,
				["M-Span"] = 30
			},
			["0.75"] = new Dictionary<string, object>
			{
				["Type"] = "K2",
				["Temperature"] = 4900,
				["L-Min"] = 0.23,
				["L-Max"] = 0.48,
				["M-Span"] = 24
			},
			["0.8"] = new Dictionary<string, object>
			{
				["Type"] = "K0",
				["Temperature"] = 5200,
				["L-Min"] = 0.28,
				["L-Max"] = 0.65,
				["M-Span"] = 20
			},
			["0.85"] = new Dictionary<string, object>
			{
				["Type"] = "G8",
				["Temperature"] = 5400,
				["L-Min"] = 0.36,
				["L-Max"] = 0.84,
				["M-Span"] = 17
			},
			["0.9"] = new Dictionary<string, object>
			{
				["Type"] = "G6",
				["Temperature"] = 5500,
				["L-Min"] = 0.45,
				["L-Max"] = 1,
				["M-Span"] = 14
			},
			["0.95"] = new Dictionary<string, object>
			{
				["Type"] = "G4",
				["Temperature"] = 5700,
				["L-Min"] = 0.56,
				["L-Max"] = 1.3,
				["M-Span"] = 12,
				["S-Span"] = 1.8,
				["G-Span"] = 1.1
			},
			["1"] = new Dictionary<string, object>
			{
				["Type"] = "G2",
				["Temperature"] = 5800,
				["L-Min"] = 0.68,
				["L-Max"] = 1.6,
				["M-Span"] = 10,
				["S-Span"] = 1.6,
				["G-Span"] = 1
			},
			["1.05"] = new Dictionary<string, object>
			{
				["Type"] = "G1",
				["Temperature"] = 5900,
				["L-Min"] = 0.87,
				["L-Max"] = 1.9,
				["M-Span"] = 8.8,
				["S-Span"] = 1.4,
				["G-Span"] = 0.8
			},
			["1.1"] = new Dictionary<string, object>
			{
				["Type"] = "G0",
				["Temperature"] = 6000,
				["L-Min"] = 1.1,
				["L-Max"] = 2.2,
				["M-Span"] = 7.7,
				["S-Span"] = 1.2,
				["G-Span"] = 0.7
			},
			["1.15"] = new Dictionary<string, object>
			{
				["Type"] = "F9",
				["Temperature"] = 6100,
				["L-Min"] = 1.4,
				["L-Max"] = 2.6,
				["M-Span"] = 6.7,
				["S-Span"] = 1,
				["G-Span"] = 0.6
			},
			["1.2"] = new Dictionary<string, object>
			{
				["Type"] = "F8",
				["Temperature"] = 6300,
				["L-Min"] = 1.7,
				["L-Max"] = 3,
				["M-Span"] = 5.9,
				["S-Span"] = 0.9,
				["G-Span"] = 0.6
			},
			["1.25"] = new Dictionary<string, object>
			{
				["Type"] = "F7",
				["Temperature"] = 6400,
				["L-Min"] = 2.1,
				["L-Max"] = 3.5,
				["M-Span"] = 5.2,
				["S-Span"] = 0.8,
				["G-Span"] = 0.5
			},
			["1.3"] = new Dictionary<string, object>
			{
				["Type"] = "F6",
				["Temperature"] = 6500,
				["L-Min"] = 2.5,
				["L-Max"] = 3.9,
				["M-Span"] = 4.6,
				["S-Span"] = 0.7,
				["G-Span"] = 0.4
			},
			["1.35"] = new Dictionary<string, object>
			{
				["Type"] = "F5",
				["Temperature"] = 6600,
				["L-Min"] = 3.1,
				["L-Max"] = 4.5,
				["M-Span"] = 4.1,
				["S-Span"] = 0.6,
				["G-Span"] = 0.4
			},
			["1.4"] = new Dictionary<string, object>
			{
				["Type"] = "F4",
				["Temperature"] = 6700,
				["L-Min"] = 3.7,
				["L-Max"] = 5.1,
				["M-Span"] = 3.7,
				["S-Span"] = 0.6,
				["G-Span"] = 0.4
			},
			["1.45"] = new Dictionary<string, object>
			{
				["Type"] = "F3",
				["Temperature"] = 6900,
				["L-Min"] = 4.3,
				["L-Max"] = 5.7,
				["M-Span"] = 3.3,
				["S-Span"] = 0.5,
				["G-Span"] = 0.3
			},
			["1.5"] = new Dictionary<string, object>
			{
				["Type"] = "F2",
				["Temperature"] = 7000,
				["L-Min"] = 5.1,
				["L-Max"] = 6.5,
				["M-Span"] = 3,
				["S-Span"] = 0.5,
				["G-Span"] = 0.3
			},
			["1.55"] = new Dictionary<string, object>
			{
				["Type"] = "F1",
				["Temperature"] = 7100,
				["L-Min"] = 5.9,
				["L-Max"] = 7.2,
				["M-Span"] = 2.8,
				["S-Span"] = 0.4,
				["G-Span"] = 0.3
			},
			["1.6"] = new Dictionary<string, object>
			{
				["Type"] = "F0",
				["Temperature"] = 7300,
				["L-Min"] = 6.7,
				["L-Max"] = 8.2,
				["M-Span"] = 2.5,
				["S-Span"] = 0.4,
				["G-Span"] = 0.2
			},
			["1.65"] = new Dictionary<string, object>
			{
				["Type"] = "A9",
				["Temperature"] = 7400,
				["L-Min"] = 7.6,
				["L-Max"] = 9.3,
				["M-Span"] = 2.3,
				["S-Span"] = 0.3,
				["G-Span"] = 0.2
			},
			["1.7"] = new Dictionary<string, object>
			{
				["Type"] = "A9",
				["Temperature"] = 7500,
				["L-Min"] = 8.6,
				["L-Max"] = 10,
				["M-Span"] = 2.1,
				["S-Span"] = 0.3,
				["G-Span"] = 0.2
			},
			["1.75"] = new Dictionary<string, object>
			{
				["Type"] = "A8",
				["Temperature"] = 7600,
				["L-Min"] = 9.7,
				["L-Max"] = 11.5,
				["M-Span"] = 1.9,
				["S-Span"] = 0.3,
				["G-Span"] = 0.2
			},
			["1.8"] = new Dictionary<string, object>
			{
				["Type"] = "A7",
				["Temperature"] = 7800,
				["L-Min"] = 11,
				["L-Max"] = 13,
				["M-Span"] = 1.8,
				["S-Span"] = 0.3,
				["G-Span"] = 0.2
			},
			["1.85"] = new Dictionary<string, object>
			{
				["Type"] = "A7",
				["Temperature"] = 7900,
				["L-Min"] = 12,
				["L-Max"] = 15,
				["M-Span"] = 1.7,
				["S-Span"] = 0.3,
				["G-Span"] = 0.2
			},
			["1.9"] = new Dictionary<string, object>
			{
				["Type"] = "A6",
				["Temperature"] = 8000,
				["L-Min"] = 13,
				["L-Max"] = 16,
				["M-Span"] = 1.5,
				["S-Span"] = 0.2,
				["G-Span"] = 0.1
			},
			["1.95"] = new Dictionary<string, object>
			{
				["Type"] = " A6",
				["Temperature"] = 8100,
				["L-Min"] = 15,
				["L-Max"] = 19,
				["M-Span"] = 1.4,
				["S-Span"] = 0.2,
				["G-Span"] = 0.1
			},
			["2"] = new Dictionary<string, object>
			{
				["Type"] = "A5",
				["Temperature"] = 8200,
				["L-Min"] = 16,
				["L-Max"] = 20,
				["M-Span"] = 1.3,
				["S-Span"] = 0.2,
				["G-Span"] = 0.1
			}
		};

		public static Dictionary<string, Dictionary<string, object>> MASSIVE_STARS = new Dictionary<string, Dictionary<string, object>>
		{
			["3"] = new Dictionary<string, object>
			{
				["Type"] = "B9",
				["Luminosity"] = 90,
				["Temperature"] = 9800,
				["Stable Span"] = 0.33
			},
			["3.5"] = new Dictionary<string, object>
			{
				["Type"] = "B8",
				["Luminosity"] = 200,
				["Temperature"] = 11000,
				["Stable Span"] = 0.2
			},
			["4"] = new Dictionary<string, object>
			{
				["Type"] = "B7",
				["Luminosity"] = 300,
				["Temperature"] = 12000,
				["Stable Span"] = 0.13
			},
			["4.5"] = new Dictionary<string, object>
			{
				["Type"] = "B6",
				["Luminosity"] = 450,
				["Temperature"] = 13000,
				["Stable Span"] = 0.1
			},
			["5"] = new Dictionary<string, object>
			{
				["Type"] = "B5",
				["Luminosity"] = 700,
				["Temperature"] = 14000,
				["Stable Span"] = 0.07
			},
			["5.5"] = new Dictionary<string, object>
			{
				["Type"] = "B4",
				["Luminosity"] = 1000,
				["Temperature"] = 15000,
				["Stable Span"] = 0.05
			},
			["6"] = new Dictionary<string, object>
			{
				["Type"] = "B3",
				["Luminosity"] = 1800,
				["Temperature"] = 16000,
				["Stable Span"] = 0.04
			},
			["7.5"] = new Dictionary<string, object>
			{
				["Type"] = "B2",
				["Luminosity"] = 3600,
				["Temperature"] = 18000,
				["Stable Span"] = 0.02
			},
			["8"] = new Dictionary<string, object>
			{
				["Type"] = "B1",
				["Luminosity"] = 5000,
				["Temperature"] = 19000,
				["Stable Span"] = 0.015
			},
			["9"] = new Dictionary<string, object>
			{
				["Type"] = "B1",
				["Luminosity"] = 8000,
				["Temperature"] = 20000,
				["Stable Span"] = 0.011
			},
			["10"] = new Dictionary<string, object>
			{
				["Type"] = "B1",
				["Luminosity"] = 11000,
				["Temperature"] = 18000,
				["Stable Span"] = 0.009
			},
			["12"] = new Dictionary<string, object>
			{
				["Type"] = "B0",
				["Luminosity"] = 20000,
				["Temperature"] = 24000,
				["Stable Span"] = 0.006
			},
			["15"] = new Dictionary<string, object>
			{
				["Type"] = "B0",
				["Luminosity"] = 58000,
				["Temperature"] = 26000,
				["Stable Span"] = 0.0026
			},
			["20"] = new Dictionary<string, object>
			{
				["Type"] = "O9",
				["Luminosity"] = 90000,
				["Temperature"] = 33000,
				["Stable Span"] = 0.0013
			},
			["22"] = new Dictionary<string, object>
			{
				["Type"] = "O9",
				["Luminosity"] = 130000,
				["Temperature"] = 34000,
				["Stable Span"] = 0.0011
			},
			["25"] = new Dictionary<string, object>
			{
				["Type"] = "O8",
				["Luminosity"] = 170000,
				["Temperature"] = 35000,
				["Stable Span"] = 0.0007
			},
			["28"] = new Dictionary<string, object>
			{
				["Type"] = "O8",
				["Luminosity"] = 244000,
				["Temperature"] = 36000,
				["Stable Span"] = 0.00057
			},
			["30"] = new Dictionary<string, object>
			{
				["Type"] = "O7",
				["Luminosity"] = 318000,
				["Temperature"] = 37000,
				["Stable Span"] = 0.00044
			},
			["35"] = new Dictionary<string, object>
			{
				["Type"] = "O7",
				["Luminosity"] = 430000,
				["Temperature"] = 40000,
				["Stable Span"] = 0.00033
			},
			["40"] = new Dictionary<string, object>
			{
				["Type"] = "O6",
				["Luminosity"] = 500000,
				["Temperature"] = 39000,
				["Stable Span"] = 0.00025
			},
			["45"] = new Dictionary<string, object>
			{
				["Type"] = "O6",
				["Luminosity"] = 540000,
				["Temperature"] = 40000,
				["Stable Span"] = 0.00019
			},
			["50"] = new Dictionary<string, object>
			{
				["Type"] = "O5",
				["Luminosity"] = 3600000,
				["Temperature"] = 40500,
				["Stable Span"] = 0.00014
			},
			["60"] = new Dictionary<string, object>
			{
				["Type"] = "O5",
				["Luminosity"] = 790000,
				["Temperature"] = 41500,
				["Stable Span"] = 0.00009
			},
			["70"] = new Dictionary<string, object>
			{
				["Type"] = "O4",
				["Luminosity"] = 900000,
				["Temperature"] = 42000,
				["Stable Span"] = 0.00006
			},
			["80"] = new Dictionary<string, object>
			{
				["Type"] = "O4",
				["Luminosity"] = 1070000,
				["Temperature"] = 42500,
				["Stable Span"] = 0.000035
			},
			["90"] = new Dictionary<string, object>
			{
				["Type"] = "O3",
				["Luminosity"] = 1100000,
				["Temperature"] = 43000,
				["Stable Span"] = 0.000016
			},
			["100"] = new Dictionary<string, object>
			{
				["Type"] = "O3",
				["Luminosity"] = 1200000,
				["Temperature"] = 44000,
				["Stable Span"] = 0.000009
			}
		};

		public static Dictionary<string, double> MASS_MAP = new Dictionary<string, double>
		{
			["3"] = 3,
			["3.5"] = 3.5,
			["4"] = 4,
			["4.5"] = 4.5,
			["5"] = 5,
			["5.5"] = 5.5,
			["6"] = 6,
			["7.5"] = 7.5,
			["8"] = 8,
			["9"] = 9,
			["10"] = 10,
			["12"] = 12,
			["15"] = 15,
			["20"] = 20,
			["22"] = 22,
			["25"] = 25,
			["28"] = 28,
			["30"] = 30,
			["35"] = 35,
			["40"] = 40,
			["45"] = 45,
			["50"] = 50,
			["60"] = 60,
			["70"] = 70,
			["80"] = 80,
			["90"] = 90,
			["100"] = 100,
		};

		public static Dictionary<string, Dictionary<string, double>> LUMINOSITY_VARIABLES = new Dictionary<string, Dictionary<string, double>>
		{
			["I"] = new Dictionary<string, double>
			{
				["Ct"] = 5520.94,
				["Et"] = 0.519,
				["Cl"] = 25557.62,
				["El"] = 1.055
			},
			["II"] = new Dictionary<string, double>
			{
				["Ct"] = 5310.42,
				["Et"] = 0.5495,
				["Cl"] = 12855.2,
				["El"] = 2.2275
			},
			["III"] = new Dictionary<string, double>
			{
				["Ct"] = 5099.91,
				["Et"] = 0.58,
				["Cl"] = 152.78,
				["El"] = 3.4
			},
			["IV"] = new Dictionary<string, double>
			{
				["Ct"] = 5447.29,
				["Et"] = 0.615,
				["Cl"] = 76.855,
				["El"] = 3.71
			},
			["V"] = new Dictionary<string, double>
			{
				["Ct"] = 5794.66,
				["Et"] = 0.65,
				["Cl"] = 0.93,
				["El"] = 4.02
			}
		};
	}
	public static class PlanetsData
	{
		public static Dictionary<string, int> ROGUE_TYPE = new Dictionary<string, int>
		{
			["Acheronian"] = 2,
			["Rockball"] = 5,
			["Snowball"] = 12,
			["Oceanic"] = 14,
			["Asphodelian"] = 15,
			["Helian"] = 16,
			["Jovian"] = 17,
			["Panthalassic"] = 18
		};

		public static Dictionary<string, int[]> DEFAULT_SIZE = new Dictionary<string, int[]>
		{
			["Asteroid"] = new int[] { 0, 3 },
			["Dwarf"] = new int[] { 3, 7 },
			["Terrestrial"] = new int[] { 6, 12 },
			["Helian"] = new int[] { 11, 17 },
			["Jovian"] = new int[] { 16, 26 }
		};

		public static Dictionary<string, int> ADJUSTED_ATMO = new Dictionary<string, int>
		{
			["0"] = 2,
			["1"] = 5,
			["10"] = 15
		};

		public static Dictionary<string, float[]> ATMO_MASS = new Dictionary<string, float[]>
		{
			["1"] = new float[] { 0, 0.01f },
			["3"] = new float[] { 0.01f, 0.5f },
			["5"] = new float[] { 0.5f, 0.8f },
			["7"] = new float[] { 0.8f, 1.2f },
			["9"] = new float[] { 1.2f, 1.5f },
			["12"] = new float[] { 1.5f, 10f }
		};

		public static Dictionary<string, int> TAINTED_ATMO = new Dictionary<string, int>
		{
			[": Chlorine"] = 3,
			[": Fluorine"] = 4,
			[": Sulfur Compounds"] = 6,
			[": Nitrogen Compounds"] = 7,
			[": Organic Toxins"] = 9,
			[": Low Oxygen"] = 11,
			[": Heavy metal pollutants"] = 12,
			[": Radioactive pollutants"] = 13,
			[": High Carbon Dioxide"] = 14,
			[": High Oxygen"] = 16,
			[": Inert Gases"] = 18
		};

		public static Dictionary<string, Dictionary<string, int>> TOXICITY_LEVEL = new Dictionary<string, Dictionary<string, int>>
		{
			[": Chlorine"] = new Dictionary<string, int>
			{
				[" (Mildly Toxic)"] = 3,
				[" (Highly Toxic)"] = 4,
				[" (Corrosive)"] = 18
			},
			[": Fluorine"] = new Dictionary<string, int>
			{
				[" (Mildly Toxic)"] = 3,
				[" (Highly Toxic)"] = 4,
				[" (Corrosive)"] = 18
			},
			[": Sulfur Compounds"] = new Dictionary<string, int>
			{
				[" (Mildly Toxic)"] = 16,
				[" (Highly Toxic)"] = 18
			},
			[": Nitrogen Compounds"] = new Dictionary<string, int>
			{
				[" (Mildly Toxic)"] = 16,
				[" (Highly Toxic)"] = 18
			},
			[": Organic Toxins"] = new Dictionary<string, int>
			{
				[" (Mildly Toxic)"] = 16,
				[" (Highly Toxic)"] = 18
			},
			[": Low Oxygen"] = new Dictionary<string, int>
			{
				[" (Suffocating)"] = 1,
				[" (Trace)"] = 3,
				[" (Very Thin)"] = 5,
				[" (Thin)"] = 7,
				[" (Standard)"] = 9,
				[""] = 18
			},
			[": Heavy metal pollutants"] = new Dictionary<string, int>
			{
				[" (Mildly Toxic)"] = 17,
				[" (Highly Toxic)"] = 18
			},
			[": Radioactive pollutants"] = new Dictionary<string, int>
			{
				[" (Mildly Toxic)"] = 14,
				[" (Highly Toxic)"] = 18
			},
			[": High Carbon Dioxide"] = new Dictionary<string, int>
			{
				[" (Uncomfortable)"] = 10,
				[" (Mildly Toxic)"] = 18
			},
			[": High Oxygen"] = new Dictionary<string, int>
			{
				[" (Very Thin)"] = 1,
				[" (Thin)"] = 3,
				[" (Standard)"] = 5,
				[" (Dense)"] = 7,
				[" (Very Dense)"] = 9,
				[" (Mildly Toxic)"] = 18
			},
			[": Inert Gases"] = new Dictionary<string, int>
			{
				[""] = 18
			}
		};
			
		public static Dictionary<string, int> ATMO_COMPOSITION = new Dictionary<string, int>
		{
			["Vacuum"] = 0,
			["Trace"] = 1,
			["Tainted, Very Thin, Breathable"] = 2,
			["Very Thin, Breathable: Nitrogen-Oxygen"] = 3,
			["Tainted, Thin, Breathable"] = 4,
			["Thin, Breathable: Nitrogen-Oxygen"] = 5,
			["Breathable: Nitrogen-Oxygen"] = 6,
			["Tainted, Breathable"] = 7,
			["Dense, Breathable: Nitrogen-Oxygen"] = 8,
			["Tainted, Dense, Breathable"] = 9,
			["Tainted, Unbreathable"] = 10,
			["Corrosive"] = 11,
			["Insidious"] = 12,
			["Tainted, Super-Dense, Unbreathable"] = 13,
			["Super-Dense, Breathable*: Nitrogen-Oxygen"] = 14,
			["Tainted, Super-Dense, Breathable*"] = 15
		};

		public static Dictionary<string, int> CLIMATE = new Dictionary<string, int>
		{
			["Frozen"] = 244,
			["Very Cold"] = 255,
			["Cold"] = 266,
			["Chilly"] = 278,
			["Cool"] = 289,
			["Normal"] = 300,
			["Warm"] = 311,
			["Tropical"] = 322,
			["Hot"] = 333,
			["Very Hot"] = 344,
			["Infernal"] = 100000
		};

		public static Dictionary<string, Dictionary<string, Dictionary<string, int>>> WORLD_CLASSES = new Dictionary<string, Dictionary<string, Dictionary<string, int>>>
		{
			["Asteroid"] = new Dictionary<string, Dictionary<string, int>>
			{
				["epistellar"] = new Dictionary<string, int>
				{
					["Rockball (Moonlet)"] = 18,
					["Hephaestian (Moonlet)"] = 30,
					["Hebean (Moonlet)"] = 34,
					["Promethean (Moonlet)"] = 36
				},
				["inner"] = new Dictionary<string, int>
				{
					["Rockball (Moonlet)"] = 11,
					["Arean (Moonlet)"] = 16,
					["Hephaestian (Moonlet)"] = 19,
					["Hebean (Moonlet)"] = 30,
					["Promethean (Moonlet)"] = 36
				},
				["outer"] = new Dictionary<string, int>
				{
					["Snowball (Moonlet)"] = 11,
					["Rockball (Moonlet)"] = 16,
					["Hephaestian (Moonlet)"] = 19,
					["Hebean (Moonlet)"] = 27,
					["Arean (Moonlet)"] = 33,
					["Promethean (Moonlet)"] = 36
				}
			},
			["Dwarf"] = new Dictionary<string, Dictionary<string, int>>
			{
				["epistellar"] = new Dictionary<string, int>
				{
					["Rockball"] = 18,
					["Hephaestian"] = 30,
					["Hebean"] = 34,
					["Hephaestian (Moonlet)"] = 36
				},
				["inner"] = new Dictionary<string, int>
				{
					["Rockball"] = 11,
					["Arean"] = 16,
					["Hephaestian"] = 19,
					["Hebean"] = 30,
					["Promethean"] = 36
				},
				["outer"] = new Dictionary<string, int>
				{
					["Snowball"] = 11,
					["Rockball"] = 16,
					["Hephaestian"] = 19,
					["Hebean"] = 27,
					["Arean"] = 33,
					["Promethean"] = 36
				}
			},
			["Terrestrial"] = new Dictionary<string, Dictionary<string, int>>
			{
				["epistellar"] = new Dictionary<string, int>
				{
					["JaniLithic"] = 21,
					["Vesperian"] = 29,
					["Telluric"] = 36
				},
				["inner"] = new Dictionary<string, int>
				{
					["Telluric"] = 14,
					["Arid"] = 21,
					["Oceanic"] = 29,
					["Tectonic"] = 26
				},
				["outer"] = new Dictionary<string, int>
				{
					["Arid"] = 21,
					["Tectonic"] = 30,
					["Oceanic"] = 36
				}
			},
			["Helian"] = new Dictionary<string, Dictionary<string, int>>
			{
				["epistellar"] = new Dictionary<string, int>
				{
					["Helian"] = 28,
					["Asphodelian"] = 36
				},
				["inner"] = new Dictionary<string, int>
				{
					["Helian"] = 25,
					["Panthalassic"] = 36
				},
				["outer"] = new Dictionary<string, int>
				{
					["Helian"] = 36
				}
			},
			["Jovian"] = new Dictionary<string, Dictionary<string, int>>
			{
				["epistellar"] = new Dictionary<string, int>
				{
					["Jovian"] = 28,
					["Chthonian"] = 36
				},
				["inner"] = new Dictionary<string, int>
				{
					["Jovian"] = 36
				},
				["outer"] = new Dictionary<string, int>
				{
					["Jovian"] = 36
				}
			}
		};

		public static Dictionary<string, string> III_CLASSES = new Dictionary<string, string>
		{
			["Asteroid"] = "Stygian",
			["Dwarf"] = "Stygian",
			["Terrestrial"] = "Acheronian",
			["Helian"] = "Asphodelian",
			["Jovian"] = "Chthonian"
		};

		public static Dictionary<string, Dictionary<string, object>> TYPE_DATA = new Dictionary<string, Dictionary<string, object>>
		{
			["Acheronian"] = new Dictionary<string, object>
			{
				["Planet_class"] = "Acheronian",
				["World_type"] = "Barren",
				["Size_Mod"] = 4,
				["Absorption"] = 0.77f,
				["Greenhouse"] = 2,
				["Atmosphere"] = new int[] { 1, 1, 0 },
				["Hydrosphere"] = new int[] { 1, 0, 0 },
				["Chemistry"] = new int[] { 1, 0, 0 },
				["Biosphere"] = new int[] { 1, 0, 0 }
			},
			["Hephaestian (Moonlet)"] = new Dictionary<string, object>
			{
				["Planet_class"] = "Hephaestian",
				["World_type"] = "Hostile",
				["Size_Sides"] = 4,
				["Absorption"] = 0.97f,
				["Greenhouse"] = 0,
				["Atmosphere"] = new int[] { 1, 1, 0 },
				["Hydrosphere"] = new int[] { 15, 1, 0 },
				["Chemistry"] = new int[] { 1, 0, 0 },
				["Biosphere"] = new int[] { 1, 0, 0 }
			},
			["JaniLithic"] = new Dictionary<string, object>
			{
				["Planet_class"] = "JaniLithic",
				["World_type"] = "Hostile",
				["Size_Mod"] = 4,
				["Absorption"] = 0.97f,
				["Greenhouse"] = 0,
				["Atmosphere"] = new int[] { 1, 6, 0 },
				["Atmosphere_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 1, 1, 0 },
					["1"] = new int[] { 1, 1, 0 },
					["2"] = new int[] { 1, 1, 0 },
					["3"] = new int[] { 1, 1, 0 },
					["4"] = new int[] { 1, 1, 0 },
					["5"] = new int[] { 1, 1, 0 },
					["6"] = new int[] { 1, 1, 0 },
					["7"] = new int[] { 1, 1, 0 },
					["8"] = new int[] { 1, 1, 0 },
					["9"] = new int[] { 1, 1, 0 },
					["10"] = new int[] { 4, 1, 0 }
				},
				["Hydrosphere"] = new int[] { 1, 0, 0 },
				["Chemistry"] = new int[] { 1, 0, 0 },
				["Biosphere"] = new int[] { 1, 0, 0 }
			},
			["Promethean (Moonlet)"] = new Dictionary<string, object>
			{
				["Planet_class"] = "Promethean",
				["World_type"] = "Garden",
				["Size_Sides"] = 4,
				["Absorption"] = 0.92f,
				["Greenhouse"] = 0.16f,
				["Atmosphere"] = new int[] { 2, 6, -7 },
				["Atmosphere_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 1, 0, 0 },
					["1"] = new int[] { 1, 0, 0 },
					["2"] = new int[] { 1, 0, 0 },
					["3"] = new int[] { 3, 1, 0 },
					["4"] = new int[] { 4, 1, 0 },
					["5"] = new int[] { 5, 1, 0 },
					["6"] = new int[] { 6, 1, 0 },
					["7"] = new int[] { 7, 1, 0 },
					["8"] = new int[] { 8, 1, 0 },
					["9"] = new int[] { 9, 1, 0 }
				},
				["Hydrosphere"] = new int[] { 2, 6, -2 },
				["Chemistry"] = new int[] { 1, 6, 0 },
				["Chemistry_results"] = new Dictionary<string, int>
				{
					["Water"] = 4,
					["Ammonia"] = 6,
					["Methane"] = 8
				},
				["Biosphere"] = new int[] { 1, 0, 0 },
				["Bio_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 1, 0, 0 },
					["1"] = new int[] { 1, 3, 0 },
					["2"] = new int[] { 2, 6, 0 }
				}
			},
			["Stygian"] = new Dictionary<string, object>
			{
				["Planet_class"] = "Stygian",
				["World_type"] = "Hostile",
				["Absorption"] = 0.77f,
				["Greenhouse"] = 0,
				["Atmosphere"] = new int[] { 1, 0, 0 },
				["Hydrosphere"] = new int[] { 1, 0, 0 },
				["Chemistry"] = new int[] { 1, 0, 0 },
				["Biosphere"] = new int[] { 1, 0, 0 }
			},
			["Stygian (Moonlet)"] = new Dictionary<string, object>
			{
				["Planet_class"] = "Stygian",
				["World_type"] = "Hostile",
				["Size_Sides"] = 4,
				["Absorption"] = 0.77f,
				["Greenhouse"] = 0,
				["Atmosphere"] = new int[] { 1, 0, 0 },
				["Hydrosphere"] = new int[] { 1, 0, 0 },
				["Chemistry"] = new int[] { 1, 0, 0 },
				["Biosphere"] = new int[] { 1, 0, 0 }
			},
			["Tectonic"] = new Dictionary<string, object>
			{
				["Planet_class"] = "Tectonic",
				["World_type"] = "Garden",
				["Size_Mod"] = 6,
				["Absorption"] = 0.92f,
				["Greenhouse"] = 0.16f,
				["Atmosphere"] = new int[] { 2, 6, -7 },
				["Atmosphere_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 1, 0, 0 },
					["1"] = new int[] { 1, 0, 0 },
					["2"] = new int[] { 1, 0, 0 },
					["3"] = new int[] { 3, 1, 0 },
					["4"] = new int[] { 4, 1, 0 },
					["5"] = new int[] { 5, 1, 0 },
					["6"] = new int[] { 6, 1, 0 },
					["7"] = new int[] { 7, 1, 0 },
					["8"] = new int[] { 8, 1, 0 },
					["9"] = new int[] { 9, 1, 0 }
				},
				["Hydrosphere"] = new int[] { 2, 6, -2 },
				["Chemistry"] = new int[] { 2, 6, 0 },
				["Chemistry_results"] = new Dictionary<string, int>
				{
					["Water"] = 8,
					["Sulfur"] = 11,
					["Chlorine"] = 13,
					["Ammonia"] = 14,
					["Methane"] = 16
				},
				["Biosphere"] = new int[] { 1, 0, 0 },
				["Bio_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 1, 0, 0 },
					["1"] = new int[] { 1, 3, 0 },
					["2"] = new int[] { 2, 6, 0 }
				}
			},
			["Arean"] = new Dictionary<string, object>
			{
				["Planet_class"] = "Arean",
				["World_type"] = "Barren",
				["Absorption"] = 0.96f,
				["Greenhouse"] = 0,
				["Atmosphere"] = new int[] { 1, 6, 0 },
				["Atmosphere_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 1, 1, 0 },
					["1"] = new int[] { 1, 1, 0 },
					["2"] = new int[] { 1, 1, 0 },
					["3"] = new int[] { 1, 1, 0 },
					["4"] = new int[] { 1, 1, 0 },
					["5"] = new int[] { 1, 1, 0 },
					["6"] = new int[] { 1, 1, 0 },
					["7"] = new int[] { 1, 1, 0 },
					["8"] = new int[] { 1, 1, 0 },
					["9"] = new int[] { 1, 1, 0 },
					["10"] = new int[] { 4, 1, 0 }
				},
				["Hydrosphere"] = new int[] { 1, 6, 0 },
				["Chemistry"] = new int[] { 1, 6, 0 },
				["Chemistry_results"] = new Dictionary<string, int>
				{
					["Water"] = 4,
					["Ammonia"] = 6,
					["Methane"] = 8
				},
				["Biosphere"] = new int[] { 1, 3, 0 },
				["Biosphere_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 1, 0, 0 },
					["1"] = new int[] { 1, 3, 0 },
					["2"] = new int[] { 1, 6, -2 },
					["3"] = new int[] { 1, 6, -4 }
				}
			},
			["Arean (Moonlet)"] = new Dictionary<string, object>
			{
				["Planet_class"] = "Arean",
				["World_type"] = "Barren",
				["Size_Sides"] = 4,
				["Absorption"] = 0.97f,
				["Greenhouse"] = 0,
				["Atmosphere"] = new int[] { 1, 6, 0 },
				["Atmosphere_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 1, 1, 0 },
					["1"] = new int[] { 1, 1, 0 },
					["2"] = new int[] { 1, 1, 0 },
					["3"] = new int[] { 1, 1, 0 },
					["4"] = new int[] { 1, 1, 0 },
					["5"] = new int[] { 1, 1, 0 },
					["6"] = new int[] { 1, 1, 0 },
					["7"] = new int[] { 1, 1, 0 },
					["8"] = new int[] { 1, 1, 0 },
					["9"] = new int[] { 1, 1, 0 },
					["10"] = new int[] { 4, 1, 0 }
				},
				["Hydrosphere"] = new int[] { 1, 6, 0 },
				["Chemistry"] = new int[] { 1, 6, 0 },
				["Chemistry_results"] = new Dictionary<string, int>
				{
					["Water"] = 4,
					["Ammonia"] = 6,
					["Methane"] = 8
				},
				["Biosphere"] = new int[] { 1, 3, 0 },
				["Biosphere_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 1, 0, 0 },
					["1"] = new int[] { 1, 3, 0 },
					["2"] = new int[] { 1, 6, -2 },
					["3"] = new int[] { 1, 6, -4 }
				}
			},
			["Arid"] = new Dictionary<string, object>
			{
				["Planet_class"] = "Arid",
				["World_type"] = "Barren",
				["Size_Sides"] = 4,
				["Absorption"] = 0.92f,
				["Greenhouse"] = 0.16f,
				["Atmosphere"] = new int[] { 2, 6, -7 },
				["Atmosphere_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 2, 1, 0 },
					["1"] = new int[] { 2, 1, 0 },
					["2"] = new int[] { 2, 1, 0 },
					["3"] = new int[] { 3, 1, 0 },
					["4"] = new int[] { 4, 1, 0 },
					["5"] = new int[] { 5, 1, 0 },
					["6"] = new int[] { 6, 1, 0 },
					["7"] = new int[] { 7, 1, 0 },
					["8"] = new int[] { 8, 1, 0 },
					["9"] = new int[] { 9, 1, 0 }
				},
				["Hydrosphere"] = new int[] { 1, 3, 0 },
				["Chemistry"] = new int[] { 1, 6, 0 },
				["Chemistry_results"] = new Dictionary<string, int>
				{
					["Water"] = 6,
					["Ammonia"] = 8,
					["Methane"] = 10
				},
				["Biosphere"] = new int[] { 1, 3, 0 },
				["Biosphere_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 1, 6, -4 },
					["1"] = new int[] { 1, 6, -4 },
					["2"] = new int[] { 1, 3, 0 },
					["3"] = new int[] { 1, 6, -2 }
				}
			},
			["Asphodelian"] = new Dictionary<string, object>
			{
				["Planet_class"] = "Asphodelian",
				["World_type"] = "Hostile",
				["Size_Mod"] = 9,
				["Absorption"] = 0.97f,
				["Greenhouse"] = 0,
				["Atmosphere"] = new int[] { 1, 1, 0 },
				["Hydrosphere"] = new int[] { 1, 0, 0 },
				["Chemistry"] = new int[] { 1, 0, 0 },
				["Biosphere"] = new int[] { 1, 0, 0 }
			},
			["Chthonian"] = new Dictionary<string, object>
			{
				["Planet_class"] = "Chthonian",
				["World_type"] = "Hostile",
				["Size_Dice"] = 2,
				["Size_Sides"] = 6,
				["Size_Mod"] = 14,
				["Absorption"] = 0.97f,
				["Greenhouse"] = 0,
				["Atmosphere"] = new int[] { 1, 1, 0 },
				["Hydrosphere"] = new int[] { 1, 0, 0 },
				["Chemistry"] = new int[] { 1, 0, 0 },
				["Biosphere"] = new int[] { 1, 0, 0 }
			},
			["Hebean"] = new Dictionary<string, object>
			{
				["Planet_class"] = "Hebean",
				["World_type"] = "Barren",
				["Absorption"] = 0.67f,
				["Greenhouse"] = 0,
				["Atmosphere"] = new int[] { 1, 6, -6 },
				["Atmosphere_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 1, 0, 0 },
					["1"] = new int[] { 1, 1, 0 },
					["2"] = new int[] { 1, 1, 0 },
					["3"] = new int[] { 1, 1, 0 },
					["4"] = new int[] { 1, 1, 0 },
					["5"] = new int[] { 1, 1, 0 },
					["6"] = new int[] { 1, 1, 0 },
					["7"] = new int[] { 1, 1, 0 },
					["8"] = new int[] { 1, 1, 0 },
					["9"] = new int[] { 1, 1, 0 },
					["10"] = new int[] { 2, 1, 0 }
				},
				["Hydrosphere"] = new int[] { 2, 6, -11 },
				["Chemistry"] = new int[] { 1, 0, 0 },
				["Biosphere"] = new int[] { 1, 0, 0 }
			},
			["Hebean (Moonlet)"] = new Dictionary<string, object>
			{
				["Planet_class"] = "Hebean",
				["World_type"] = "Barren",
				["Size_Sides"] = 4,
				["Absorption"] = 0.67f,
				["Greenhouse"] = 0,
				["Atmosphere"] = new int[] { 1, 6, -6 },
				["Atmosphere_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 1, 0, 0 },
					["1"] = new int[] { 1, 1, 0 },
					["2"] = new int[] { 1, 1, 0 },
					["3"] = new int[] { 1, 1, 0 },
					["4"] = new int[] { 1, 1, 0 },
					["5"] = new int[] { 1, 1, 0 },
					["6"] = new int[] { 1, 1, 0 },
					["7"] = new int[] { 1, 1, 0 },
					["8"] = new int[] { 1, 1, 0 },
					["9"] = new int[] { 1, 1, 0 },
					["10"] = new int[] { 2, 1, 0 }
				},
				["Hydrosphere"] = new int[] { 2, 6, -11 },
				["Chemistry"] = new int[] { 1, 0, 0 },
				["Biosphere"] = new int[] { 1, 0, 0 }
			},
			["Helian"] = new Dictionary<string, object>
			{
				["Planet_class"] = "Helian",
				["World_type"] = "Hostile",
				["Size_Mod"] = 9,
				["Absorption"] = 0.84f,
				["Greenhouse"] = 0.2f,
				["Atmosphere"] = new int[] { 13, 1, 0 },
				["Hydrosphere"] = new int[] { 1, 6, 0 },
				["Hydro_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 2, 1, 0 },
					["1"] = new int[] { 2, 1, 0 },
					["2"] = new int[] { 2, 1, 0 },
					["3"] = new int[] { 2, 1, 0 },
					["4"] = new int[] { 2, 6, -1 },
					["5"] = new int[] { 2, 6, -1 },
					["6"] = new int[] { 15, 1, 0 }
				},
				["Chemistry"] = new int[] { 1, 0, 0 },
				["Biosphere"] = new int[] { 1, 0, 0 }
			},
			["Hephaestian"] = new Dictionary<string, object>
			{
				["Planet_class"] = "Hephaestian",
				["World_type"] = "Hostile",
				["Size_Mod"] = 0,
				["Absorption"] = 0.97f,
				["Greenhouse"] = 0,
				["Atmosphere"] = new int[] { 1, 1, 0 },
				["Hydrosphere"] = new int[] { 15, 1, 0 },
				["Chemistry"] = new int[] { 1, 0, 0 },
				["Biosphere"] = new int[] { 1, 0, 0 }
			},
			["Jovian"] = new Dictionary<string, object>
			{
				["Planet_class"] = "Jovian",
				["World_type"] = "Hostile",
				["Size_Dice"] = 2,
				["Size_Sides"] = 6,
				["Size_Mod"] = 14,
				["Absorption"] = 0.77f,
				["Greenhouse"] = 2,
				["Atmosphere"] = new int[] { 15, 1, 0 },
				["Hydrosphere"] = new int[] { 15, 1, 0 },
				["Chemistry"] = new int[] { 1, 6, 0 },
				["Chemistry_results"] = new Dictionary<string, int>
				{
					["Water"] = 4,
					["Ammonia"] = 6
				},
				["Biosphere"] = new int[] { 1, 6, 0 },
				["Bio_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 5, 1, 0 },
					["1"] = new int[] { 1, 3, 0 },
					["2"] = new int[] { 2, 6, 0 }
				}
			},
			["Oceanic"] = new Dictionary<string, object>
			{
				["Planet_class"] = "Oceanic",
				["World_type"] = "Barren",
				["Size_Mod"] = 6,
				["Absorption"] = 0.84f,
				["Greenhouse"] = 0.16f,
				["Atmosphere"] = new int[] { 2, 6, -6 },
				["Atmosphere_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 1, 0, 0 },
					["1"] = new int[] { 1, 0, 0 },
					["2"] = new int[] { 2, 1, 0 },
					["3"] = new int[] { 3, 1, 0 },
					["4"] = new int[] { 4, 1, 0 },
					["5"] = new int[] { 5, 1, 0 },
					["6"] = new int[] { 6, 1, 0 },
					["7"] = new int[] { 7, 1, 0 },
					["8"] = new int[] { 8, 1, 0 },
					["9"] = new int[] { 9, 1, 0 },
					["10"] = new int[] { 10, 1, 0 },
					["11"] = new int[] { 11, 1, 0 },
					["12"] = new int[] { 12, 1, 0 }
				},
				["Atmo2_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 1, 1, 0 },
					["1"] = new int[] { 1, 1, 0 },
					["2"] = new int[] { 1, 1, 0 },
					["3"] = new int[] { 1, 1, 0 },
					["4"] = new int[] { 1, 1, 0 },
					["5"] = new int[] { 1, 1, 0 },
					["6"] = new int[] { 1, 1, 0 },
					["7"] = new int[] { 1, 1, 0 },
					["8"] = new int[] { 1, 1, 0 },
					["9"] = new int[] { 1, 1, 0 },
					["10"] = new int[] { 2, 1, 0 },
					["11"] = new int[] { 2, 1, 0 },
					["12"] = new int[] { 2, 1, 0 },
					["13"] = new int[] { 5, 1, 0 }
				},
				["Hydrosphere"] = new int[] { 11, 1, 0 },
				["Chemistry"] = new int[] { 1, 6, 0 },
				["Chemistry_results"] = new Dictionary<string, int>
				{
					["Water"] = 6,
					["Ammonia"] = 8,
					["Methane"] = 10
				},
				["Biosphere"] = new int[] { 1, 3, 0 },
				["Bio_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 1, 0, 0 },
					["1"] = new int[] { 1, 3, 0 },
					["2"] = new int[] { 2, 6, 0 }
				}
			},
			["Panthalassic"] = new Dictionary<string, object>
			{
				["Planet_class"] = "Panthalassic",
				["World_type"] = "Hostile",
				["Size_Mod"] = 9,
				["Absorption"] = 0.77f,
				["Greenhouse"] = 2,
				["Atmosphere"] = new int[] { 5, 1, 8 },
				["Hydrosphere"] = new int[] { 11, 1, 0 },
				["Chemistry"] = new int[] { 1, 6, 0 },
				["Chemistry_results"] = new Dictionary<string, int>
				{
					["Water"] = 0,
					["Sulfur"] = 9,
					["Chlorine"] = 12,
					["Ammonia"] = 13,
					["Methane"] = 15
				},
				["Biosphere"] = new int[] { 1, 0, 0 },
				["Bio_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 1, 0, 0 },
					["1"] = new int[] { 1, 3, 0 },
					["2"] = new int[] { 2, 6, 0 }
				}
			},
			["Promethean"] = new Dictionary<string, object>
			{
				["Planet_class"] = "Promethean",
				["World_type"] = "Garden",
				["Absorption"] = 0.92f,
				["Greenhouse"] = 0.16f,
				["Atmosphere"] = new int[] { 2, 6, -7 },
				["Atmosphere_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 1, 0, 0 },
					["1"] = new int[] { 1, 0, 0 },
					["2"] = new int[] { 1, 0, 0 },
					["3"] = new int[] { 3, 1, 0 },
					["4"] = new int[] { 4, 1, 0 },
					["5"] = new int[] { 5, 1, 0 },
					["6"] = new int[] { 6, 1, 0 },
					["7"] = new int[] { 7, 1, 0 },
					["8"] = new int[] { 8, 1, 0 },
					["9"] = new int[] { 9, 1, 0 }
				},
				["Hydrosphere"] = new int[] { 2, 6, -2 },
				["Chemistry"] = new int[] { 1, 6, 0 },
				["Chemistry_results"] = new Dictionary<string, int>
				{
					["Water"] = 4,
					["Ammonia"] = 6,
					["Methane"] = 8
				},
				["Biosphere"] = new int[] { 1, 0, 0 },
				["Bio_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 1, 0, 0 },
					["1"] = new int[] { 1, 3, 0 },
					["2"] = new int[] { 2, 6, 0 }
				}
			},
			["Rockball"] = new Dictionary<string, object>
			{
				["Planet_class"] = "Rockball",
				["World_type"] = "Barren",
				["Absorption"] = 0.94f,
				["Greenhouse"] = 0,
				["Atmosphere"] = new int[] { 1, 0, 0 },
				["Hydrosphere"] = new int[] { 2, 6, -11 },
				["Chemistry"] = new int[] { 1, 0, 0 },
				["Biosphere"] = new int[] { 1, 0, 0 }
			},
			["Rockball (Moonlet)"] = new Dictionary<string, object>
			{
				["Planet_class"] = "Rockball",
				["World_type"] = "Barren",
				["Size_Sides"] = 4,
				["Absorption"] = 0.94f,
				["Greenhouse"] = 0,
				["Atmosphere"] = new int[] { 1, 0, 0 },
				["Hydrosphere"] = new int[] { 2, 6, -11 },
				["Chemistry"] = new int[] { 1, 0, 0 },
				["Biosphere"] = new int[] { 1, 0, 0 }
			},
			["Snowball"] = new Dictionary<string, object>
			{
				["Planet_class"] = "Snowball",
				["World_type"] = "Barren",
				["Absorption"] = 0.93f,
				["Greenhouse"] = 0.1f,
				["Atmosphere"] = new int[] { 1, 6, 0 },
				["Atmosphere_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 1, 1, 0 },
					["1"] = new int[] { 5, 1, 0 }
				},
				["Hydrosphere"] = new int[] { 10, 1, 0 },
				["Chemistry"] = new int[] { 1, 6, 0 },
				["Chemistry_results"] = new Dictionary<string, int>
				{
					["Water"] = 4,
					["Ammonia"] = 6,
					["Methane"] = 8
				},
				["Biosphere"] = new int[] { 1, 6, 0 },
				["Biosphere_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 1, 0, 0 },
					["1"] = new int[] { 1, 6, -3 },
					["2"] = new int[] { 1, 6, -2 }
				}
			},
			["Snowball (Moonlet)"] = new Dictionary<string, object>
			{
				["Planet_class"] = "Snowball",
				["World_type"] = "Barren",
				["Size_Sides"] = 4,
				["Absorption"] = 0.93f,
				["Greenhouse"] = 0.1f,
				["Atmosphere"] = new int[] { 1, 3, 0 },
				["Atmosphere_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 1, 1, 0 },
					["1"] = new int[] { 5, 1, 0 }
				},
				["Hydrosphere"] = new int[] { 10, 1, 0 },
				["Chemistry"] = new int[] { 1, 6, 0 },
				["Chemistry_results"] = new Dictionary<string, int>
				{
					["Water"] = 4,
					["Ammonia"] = 6,
					["Methane"] = 8
				},
				["Biosphere"] = new int[] { 1, 3, 0 },
				["Biosphere_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 1, 0, 0 },
					["1"] = new int[] { 1, 6, -3 },
					["2"] = new int[] { 1, 6, -2 }
				}
			},
			["Telluric"] = new Dictionary<string, object>
			{
				["Planet_class"] = "Telluric",
				["World_type"] = "Hostile",
				["Absorption"] = 0.67f,
				["Greenhouse"] = 0,
				["Size_Sides"] = 6,
				["Size_Mod"] = 4,
				["Atmosphere"] = new int[] { 12, 1, 0 },
				["Hydrosphere"] = new int[] { 1, 6, 0 },
				["Hydro_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 4, 1, 0 },
					["1"] = new int[] { 4, 1, 0 },
					["2"] = new int[] { 4, 1, 0 },
					["3"] = new int[] { 4, 1, 0 },
					["4"] = new int[] { 4, 1, 0 },
					["5"] = new int[] { 4, 1, 0 },
					["6"] = new int[] { 4, 1, 0 },
					["7"] = new int[] { 4, 1, 0 },
					["8"] = new int[] { 4, 1, 0 },
					["9"] = new int[] { 4, 1, 0 },
					["10"] = new int[] { 4, 1, 0 },
					["11"] = new int[] { 4, 1, 0 },
					["12"] = new int[] { 4, 1, 0 },
					["13"] = new int[] { 4, 1, 0 },
					["14"] = new int[] { 4, 1, 0 },
					["15"] = new int[] { 6, 1, 0 }
				},
				["Chemistry"] = new int[] { 1, 0, 0 },
				["Biosphere"] = new int[] { 1, 0, 0 }
			},
			["Vesperian"] = new Dictionary<string, object>
			{
				["Planet_class"] = "Vesperian",
				["World_type"] = "Barren",
				["Absorption"] = 0.77f,
				["Greenhouse"] = 2,
				["Size_Mod"] = 4,
				["Atmosphere"] = new int[] { 2, 6, -7 },
				["Atmosphere_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 1, 0, 0 },
					["1"] = new int[] { 1, 0, 0 },
					["2"] = new int[] { 1, 0, 0 },
					["3"] = new int[] { 3, 1, 0 },
					["4"] = new int[] { 4, 1, 0 },
					["5"] = new int[] { 5, 1, 0 },
					["6"] = new int[] { 6, 1, 0 },
					["7"] = new int[] { 7, 1, 0 },
					["8"] = new int[] { 8, 1, 0 },
					["9"] = new int[] { 9, 1, 0 }
				},
				["Hydrosphere"] = new int[] { 2, 6, -2 },
				["Chemistry"] = new int[] { 2, 6, 0 },
				["Chemistry_results"] = new Dictionary<string, int>
				{
					["Water"] = 10,
					["Chlorine"] = 12
				},
				["Biosphere"] = new int[] { 1, 0, 0 },
				["Bio_results"] = new Dictionary<string, int[]>
				{
					["0"] = new int[] { 1, 0, 0 },
					["1"] = new int[] { 1, 3, 0 },
					["2"] = new int[] { 2, 6, 0 }
				}
			}
		};

		public static Dictionary<string, int> CHEM_MOD = new Dictionary<string, int>
		{
			["None"] = 0,
			["Water"] = 0,
			["Sulfur"] = 0,
			["Chlorine"] = 0,
			["Ammonia"] = 1,
			["Methane"] = 3
		};

		public static Dictionary<string, Dictionary<string, string>> CORETYPE = new Dictionary<string, Dictionary<string, string>>
		{
			["Tiny"] = new Dictionary<string, string>
			{
				["epistellar"] = "Iron1",
				["inner"] = "Iron1",
				["outer"] = "Icy"
			},
			["Small"] = new Dictionary<string, string>
			{
				["epistellar"] = "Iron1",
				["inner"] = "Iron1",
				["outer"] = "Icy"
			},
			["Standard"] = new Dictionary<string, string>
			{
				["epistellar"] = "Iron1",
				["inner"] = "Iron1",
				["outer"] = "Icy"
			},
			["Large"] = new Dictionary<string, string>
			{
				["epistellar"] = "Iron2",
				["inner"] = "Iron2",
				["outer"] = "Iron1"
			},
			["Giant"] = new Dictionary<string, string>
			{
				["epistellar"] = "Iron2",
				["inner"] = "Gas1",
				["outer"] = "Gas2"
			},
			["Super-Giant"] = new Dictionary<string, string>
			{
				["epistellar"] = "Gas1",
				["inner"] = "Gas2",
				["outer"] = "Gas3"
			}
		};

		public static Dictionary<string, Dictionary<string, int>> CORE_DENSITY = new Dictionary<string, Dictionary<string, int>>
		{
			["Icy"] = new Dictionary<string, int>
			{
				["0.3"] = 6,
				["0.4"] = 10,
				["0.5"] = 14,
				["0.6"] = 17,
				["0.7"] = 18
			},
			["Iron1"] = new Dictionary<string, int>
			{
				["0.6"] = 6,
				["0.7"] = 10,
				["0.8"] = 14,
				["0.9"] = 17,
				["1"] = 18
			},
			["Iron2"] = new Dictionary<string, int>
			{
				["0.8"] = 6,
				["0.9"] = 10,
				["1"] = 14,
				["1.1"] = 17,
				["1.2"] = 18
			},
			["Gas1"] = new Dictionary<string, int>
			{
				["0.42"] = 8,
				["0.26"] = 10,
				["0.22"] = 11,
				["0.19"] = 12,
				["0.17"] = 18
			},
			["Gas2"] = new Dictionary<string, int>
			{
				["0.18"] = 8,
				["0.19"] = 10,
				["0.2"] = 11,
				["0.22"] = 12,
				["0.24"] = 13,
				["0.25"] = 14,
				["0.26"] = 15,
				["0.27"] = 16,
				["0.29"] = 18
			},
			["Gas3"] = new Dictionary<string, int>
			{
				["0.31"] = 8,
				["0.35"] = 10,
				["0.4"] = 11,
				["0.6"] = 12,
				["0.8"] = 13,
				["1"] = 14,
				["1.2"] = 15,
				["1.4"] = 16,
				["1.6"] = 18
			}
		};

		public static Dictionary<string, int> AXIAL_TILT = new Dictionary<string, int>
		{
			["0"] = 6,
			["10"] = 9,
			["20"] = 12,
			["30"] = 14,
			["40"] = 16,
			["50"] = 20,
			["60"] = 24,
			["70"] = 25,
			["80"] = 26
		};

		public static Dictionary<string, Dictionary<string, float>> TIDAL_ADJUST = new Dictionary<string, Dictionary<string, float>>
		{
			["Trace"] = new Dictionary<string, float>
			{
				["Day"] = 1.2f,
				["Night"] = 0.1f,
				["Final_Atmo"] = 0f,
				["Hydro_Penalty"] = -100f
			},
			["Very Thin"] = new Dictionary<string, float>
			{
				["Day"] = 1.2f,
				["Night"] = 0.1f,
				["Final_Atmo"] = 1f,
				["Hydro_Penalty"] = -100f
			},
			["Thin"] = new Dictionary<string, float>
			{
				["Day"] = 1.16f,
				["Night"] = 0.67f,
				["Hydro_Penalty"] = -50f
			},
			["Standard"] = new Dictionary<string, float>
			{
				["Day"] = 1.12f,
				["Night"] = 0.8f,
				["Hydro_Penalty"] = -25f
			},
			["Dense"] = new Dictionary<string, float>
			{
				["Day"] = 1.09f,
				["Night"] = 0.88f,
				["Hydro_Penalty"] = -10f
			},
			["Very Dense"] = new Dictionary<string, float>
			{
				["Day"] = 1.05f,
				["Night"] = 0.95f,
				["Hydro_Penalty"] = 0f
			},
			["Superdense"] = new Dictionary<string, float>
			{
				["Day"] = 1f,
				["Night"] = 1f,
				["Hydro_Penalty"] = 0f
			}
		};

		public static Dictionary<string, int> VOLCANIC_ACTIVITY = new Dictionary<string, int>
		{
			["None"] = 16,
			["Light"] = 20,
			["Moderate"] = 26,
			["Heavy"] = 70,
			["Extreme"] = 500
		};

		public static Dictionary<string, int> TECTONIC_ACTIVITY = new Dictionary<string, int>
		{
			["None"] = 6,
			["Light"] = 10,
			["Moderate"] = 14,
			["Heavy"] = 18,
			["Extreme"] = 300
		};

		public static Dictionary<string, int> WORLD_RESOURCES = new Dictionary<string, int>
		{
			["-3"] = 2,
			["-2"] = 4,
			["-1"] = 7,
			["0"] = 13,
			["1"] = 16,
			["2"] = 18,
			["3"] = 20
		};
	}
}

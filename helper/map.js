export const deptMap = { M: 1, C: 2, A: 5 };

export const levelMap = { 4: 1, 9: 2, 10: 3, 11: 4, 12: 5 };

export const activeStatusMap = { A: true, I: false };

export const moduleMap = (() => {
	// original mapping (from key -> value)
	const original = {
		1: 26,
		2: 27,
		3: 86,
		4: 51,
		5: 34,
		6: 36,
		7: 38,
		8: 45,
		9: 46,
		10: 48,
		11: 35,
		12: 49,
		13: 43,
		14: 44,
		15: 52,
		16: 50,
		17: 61,
		18: 53,
		19: 54,
		20: 55,
		21: 58,
		22: 89,
		23: 56,
		24: 60,
		25: 94,
		26: 63,
		27: 96,
		28: 97,
		29: 95,
		30: 62,
		31: 59,
		32: 65,
		33: 67,
		34: 66,
		35: 88,
		36: 71,
		37: 90,
		42: 87,
		50: 68,
		51: 75,
		52: 49,
		53: 76,
		54: 82,
		55: 80,
		57: 112,
		56: 81,
		60: 98,
		61: 99,
		62: 77,
		63: 29,
		46: 31,
		47: 103,
		48: 57,
		59: 30
	};

	// build swapped mapping (value -> key). If multiple keys map to same value, store them in an array.
	const swapped = {};
	for (const [k, v] of Object.entries(original)) {
		const numKey = Number(k);
		const outKey = String(v);
		if (Object.prototype.hasOwnProperty.call(swapped, outKey)) {
			if (Array.isArray(swapped[outKey])) swapped[outKey].push(numKey);
			else swapped[outKey] = [swapped[outKey], numKey];
		} else {
			swapped[outKey] = numKey;
		}
	}
	return swapped;
})()

// The module IDs that do not exist in the new system (yet) and should default to 64
// 91, 92, 101, 102, 93, 84, 78, 74, 85, 106, 110, 113, 114, 111, 116, 115, 124
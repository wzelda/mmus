using System;
using UnityEngine;

namespace FishBehavior
{
	[Serializable]
	public struct MyRange
	{
		[SerializeField]
		private float _min;

		[SerializeField]
		private float _max;

		[SerializeField]
		private float _current;

		public static MyRange zero = new MyRange(0f, 0f);

		public float Min
		{
			get
			{
				return this._min;
			}
			set
			{
				this._min = value;
			}
		}

		public float Max
		{
			get
			{
				return this._max;
			}
			set
			{
				this._max = value;
			}
		}
		public float Middle
		{
			get
			{
				return (_max + _min) / 2;
			}
		}

		public float Current
		{
			get
			{
				return this._current;
			}
			private set
			{
				this._current = value;
			}
		}

		public MyRange(float min_, float max_)
		{
			this._min = min_;
			this._max = max_;
			this._current = min_;
		}

		public float SetCurrentRandom()
		{
			this._current = this.GetRandom();
			return this._current;
		}

		public float GetRandom()
		{
			return UnityEngine.Random.Range(this._min, this._max);
		}

		public float GetLength()
		{
			return this._max - this._min;
		}
	}
}

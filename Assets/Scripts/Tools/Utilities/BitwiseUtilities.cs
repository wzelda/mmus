/// <summary>
/// 位运算工具类
/// </summary>
public class BitwiseUtilities {

	/// <summary>
	/// 与
	/// </summary>
	public static int And(int a, int b)
	{
		return a & b;
	}

	/// <summary>
	/// 或
	/// </summary>
	public static int Or(int a, int b)
	{
		return a | b;
	}

	/// <summary>
	/// 异或
	/// </summary>
	public static int ExclusiveOr(int a, int b)
	{
		return a ^ b;
	}
	
	/// <summary>
	/// 非
	/// </summary>
	public static int Not(int a)
	{
		return ~a;
	}

	/// <summary>
	/// 左移
	/// </summary>
	public static int LeftShift(int a, int b)
	{
		return a << b;
	} 

	/// <summary>
	/// 右移
	/// </summary>
	public static int RightShift(int a, int b)
	{
		return a >> b;
	}

	/// <summary>
	/// 得到值a的第b位的值
	/// </summary>
	public static int CheckIndexValue(int a, int b)
	{
		int temp = b - 1;
		int result = (a & (1 << temp)) >> temp;
		return result;
	}
}

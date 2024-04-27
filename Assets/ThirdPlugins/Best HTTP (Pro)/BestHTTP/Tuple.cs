namespace BestHTTP
{
    public class Tuple<T1, T2>
    {
        public Tuple(T1 item1, T2 item2)
        {
            this.Item1 = item1;
            this.Item2 = item2;
        }

        public T1 Item1 { get; private set; }

        public T2 Item2 { get; private set; }

        public override bool Equals(object obj)
        {
            Tuple<T1, T2> tuple = obj as Tuple<T1, T2>;
            if (tuple == null || !object.Equals((object) this.Item1, (object) tuple.Item1))
                return false;
            return object.Equals((object) this.Item2, (object) tuple.Item2);
        }

        public override int GetHashCode()
        {
            return ((object) this.Item1 == null ? 0 : this.Item1.GetHashCode()) ^ ((object) this.Item2 == null ? 0 : this.Item2.GetHashCode());
        }
        
    }
    
    public static class Tuple
    {
        public static Tuple<T1, T2> Create<T1, T2>(T1 t1, T2 t2)
        {
            return new Tuple<T1, T2>(t1, t2);
        }
    }
}

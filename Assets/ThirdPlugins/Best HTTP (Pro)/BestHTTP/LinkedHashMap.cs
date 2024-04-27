using System;
using System.Collections.Generic;

namespace BestHTTP
{
    public class LinkedHashMap<T, U>
    {

            Dictionary<T, LinkedListNode<Tuple<U, T>>> D = new Dictionary<T, LinkedListNode<Tuple<U, T>>>();
            LinkedList<Tuple<U,T>> LL = new LinkedList<Tuple<U, T>>();

            public bool Remove(T key, out U result)
            {
                LinkedListNode<Tuple<U, T>> node;

                if (D.TryGetValue(key, out node))
                {
                    LL.Remove(node);
                    D.Remove(key);

                    result = node.Value.Item1;
                    return true;
                }

                result = default(U);
                return false;
            }

            public bool Remove(T key)
            {
                LinkedListNode<Tuple<U, T>> node;

                if (D.TryGetValue(key, out node))
                {
                    LL.Remove(node);
                    D.Remove(key);

                    return true;
                }

                return false;
            }
            
            public LinkedList<Tuple<U,T>> List()
            {
                return LL;
            }

            public bool TryGetValue(T key, out U result)
            {
                
                LinkedListNode<Tuple<U, T>> node;
                if (D.TryGetValue(key, out node))
                {
                    result = node.Value.Item1;
                    return true;
                }

                result = default(U);
                return false;
            }

            public bool Contains(T key)
            {
                return D.ContainsKey(key);
            }
            
            public LinkedList<Tuple<U,T>> Values()
            {
                return LL;
            }

            public LinkedListNode<Tuple<U, T>> AddLast(T key, U value)
            {
                if (D.ContainsKey(key))
                {
                    return null;
                }
                
                var node = new LinkedListNode<Tuple<U, T>>(Tuple.Create(value, key));
                D[key] = node;
                LL.AddLast(node);
                return node;
            }

            public LinkedListNode<Tuple<U, T>> AddFirst(T key, U value)
            {
                if (D.ContainsKey(key))
                {
                    return null;
                }
                
                var node = new LinkedListNode<Tuple<U, T>>(Tuple.Create(value, key));
                D[key] = node;
                LL.AddFirst(node);
                return node;
            }

            public LinkedListNode<Tuple<U, T>> LastNode()
            {
                return LL.Last;
            }
            
            public LinkedListNode<Tuple<U, T>> FirstNode()
            {
                return LL.First;
            }

            public U Last()
            {
                return LL.Last.Value.Item1;
            }
            
            public U First()
            {
                var node = LL.First;
                return node.Value.Item1;
            }

            public U PopFirst()
            {
                var node = LL.First;
                LL.Remove(node);
                D.Remove(node.Value.Item2);
                return node.Value.Item1;
            }

            public int Count
            {
                get
                {
                    return LL.Count;
                }
            }
        
    }
}
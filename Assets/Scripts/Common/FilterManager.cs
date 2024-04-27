using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ToolGood.Words;

namespace LPCFramework
{
    public class FilterManager : Singleton<FilterManager>
    {

        private StringSearchEx _stringSearchEx = new StringSearchEx();

        public void Init(string path)
        {
            _ReadFilterWords(path);
        }

        private void _ReadFilterWords(string path)
        {
            List<string> list = new List<string>();
            using (StreamReader sw = new StreamReader(File.OpenRead(path)))
            {
                string key = sw.ReadLine();
                while (key != null)
                {
                    if (key != string.Empty)
                    {
                        list.Add(key);
                    }
                    key = sw.ReadLine();
                }
            }

            _stringSearchEx.SetKeywords(list);
        }

        // 判断是否包含屏蔽字
        public bool ContainsKeyWords(string text)
        {
            return _stringSearchEx.ContainsAny(text);
        }

        // 替换屏蔽字
        public string ReplaceKeyWords(string text, char replaceChar = '*')
        {
            return _stringSearchEx.Replace(text, replaceChar);
        }

        public void Clear()
        {
            
        }
    }
}

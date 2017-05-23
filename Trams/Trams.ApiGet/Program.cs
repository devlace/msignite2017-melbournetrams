using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SODA;
using System.IO;
using Newtonsoft.Json;
using System.Data;
using CsvHelper;

namespace Trams.ApiGet
{
    class Program
    {
        static void Main(string[] args)
        {
            var modifiedDate = DateTime.Now;
            Console.WriteLine("year: " + Convert.ToInt32(modifiedDate.ToString("yyyy")));
            Console.WriteLine("month: " + modifiedDate.ToString("MMMM"));
            Console.WriteLine("month_num: " + Convert.ToInt32(modifiedDate.ToString("%M")));
            Console.WriteLine("m_date: " + Convert.ToInt32(modifiedDate.ToString("%d")));
            Console.WriteLine("day: " + modifiedDate.ToString("dddd"));
            Console.WriteLine("hour: " + Convert.ToInt32(modifiedDate.ToString("%H")));
            Console.WriteLine("date_time: " + modifiedDate.ToString("yyyy-MM-dd HH:mm"));

            Console.ReadLine();

            var client = new SodaClient("https://data.melbourne.vic.gov.au", "7WoqTdGEDWbjhU7O2jh9WOfFU");

            // Get a reference to the resource itself
            // The result (a Resouce object) is a generic type
            // The type parameter represents the underlying rows of the resource
            // and can be any JSON-serializable class



            var dataset = client.GetResource<data>("mxb8-wn4w");

            // Resource objects read their own data
            //var rows = dataset.GetRows(limit: 5000);

            var soql = new SoqlQuery()
                          .Where("year = 2016 and month = 'October' and mdate = 1 and time = 7");

            //year = 2016 and month = 'December' and mdate = 28 and hour = 7
            //year = 2016 and month = 'May' and mdate = 1

            var rows = dataset.Query<data>(soql);
            var csv = LinqToCSV.ToCsv<data>(rows);

            Console.WriteLine("Got {0} results. Dumping first results:", rows.Count());

            foreach (var keyValue in rows)
            {
                Console.WriteLine(keyValue);
            }
            Console.ReadLine();

            
        }

    }

    

    public static class LinqToCSV
    {
        public static string ToCsv<T>(this IEnumerable<T> items)
        where T : class
        {
            var csvBuilder = new StringBuilder();
            var properties = typeof(T).GetProperties();
            foreach (T item in items)
            {
                string line = string.Join(",", properties.Select(p => p.GetValue(item, null).ToCsvValue()).ToArray());
                csvBuilder.AppendLine(line);
            }
            return csvBuilder.ToString();
        }

        private static string ToCsvValue<T>(this T item)
        {
            if (item == null) return "\"\"";

            if (item is string)
            {
                return string.Format("\"{0}\"", item.ToString().Replace("\"", "\\\""));
            }
            double dummy;
            if (double.TryParse(item.ToString(), out dummy))
            {
                return string.Format("{0}", item);
            }
            return string.Format("\"{0}\"", item);
        }


    }

    
    public class data
    {
        public string daet_time { get; set; }
        public string day { get; set; }
        public string id { get; set; }
        public string mdate { get; set; }
        public string month { get; set; }
        public string qv_market_peel_st { get; set; }
        public string sensor_id { get; set; }
        public string sensor_name { get; set; }
        public string time { get; set; }
        public string year { get; set; }
    }
}

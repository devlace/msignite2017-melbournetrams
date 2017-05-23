using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Trams.DF.ApiDownload
{
    public class SensorData
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

    public class SensorDataClean
    {
        public int year { get; set; }
        public string month { get; set; }
        public int month_num { get; set; }
        public int mdate { get; set; }
        public string day { get; set; }
        public int hour { get; set; }
        public string date_time { get; set; }
        public string sensor_id { get; set; }
        public string sensor_name { get; set; }
        public int hourly_counts { get; set; }
        
    }
}

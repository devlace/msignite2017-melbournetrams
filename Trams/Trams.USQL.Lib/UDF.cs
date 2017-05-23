using Microsoft.Analytics.Interfaces;
using Microsoft.Analytics.Types.Sql;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace Trams.USQL.Lib
{
    public class UDF
    {
        public static int isFreeTramZone(int year)
        {
            return year >= 2015 ? 1 : 0;
        }
    }
}
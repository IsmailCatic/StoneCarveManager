using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Model.Responses.Analytics
{
    public class DailyIncomeResponse
    {
        public DateTime Date { get; set; }
        public decimal Amount { get; set; }
    }
}

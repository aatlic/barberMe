using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BarberMe.Database.Models
{
    public class PaymentStatus
    {
        public int PaymentStatusId { get; set; }
        public string Name { get; set; } = string.Empty;

        public ICollection<Payment> Payments { get; set; } = new List<Payment>();
    }
}

using System.ComponentModel.DataAnnotations;

namespace BarberMe.Model.SearchObjects
{
    public class ReportSearchObject
    {
        [Required]
        public DateTime? DateFrom { get; set; }

        [Required]
        public DateTime? DateTo { get; set; }

        public int? BarberId { get; set; }
    }
}
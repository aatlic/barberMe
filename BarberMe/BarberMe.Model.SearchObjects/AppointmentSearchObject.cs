using BarberMe.Model.Enum;

namespace BarberMe.Model.SearchObjects
{
    public class AppointmentSearchObject : BaseSearchObject
    {
        public int? ClientId { get; set; }

        public int? BarberId { get; set; }

        public int? AppointmentStatusId { get; set; }

        public DateTime? DateFrom { get; set; }

        public DateTime? DateTo { get; set; }
        public AppointmentListType? ListType { get; set; }
        public int? ServiceId { get; set; }
    }
}

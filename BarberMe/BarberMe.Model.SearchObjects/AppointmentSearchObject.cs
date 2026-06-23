namespace BarberMe.Model.SearchObjects
{
    public class AppointmentSearchObject : BaseSearchObject
    {
        public int? ClientId { get; set; }

        public int? BarberId { get; set; }

        public int? AppointmentStatusId { get; set; }

        public DateTime? DateFrom { get; set; }

        public DateTime? DateTo { get; set; }
    }
}

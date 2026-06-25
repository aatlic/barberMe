namespace BarberMe.Model.SearchObjects
{
    public class ReviewSearchObject : BaseSearchObject
    {
        public int? ClientId { get; set; }

        public int? BarberId { get; set; }

        public int? Rating { get; set; }
    }
}

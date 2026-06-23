namespace BarberMe.Model.SearchObjects
{
    public class ReviewSearchObject : BaseSearchObject
    {
        public int? BarberId { get; set; }

        public int? Rating { get; set; }
    }
}

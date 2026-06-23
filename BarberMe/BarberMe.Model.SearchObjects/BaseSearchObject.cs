namespace BarberMe.Model.SearchObjects
{
    public class BaseSearchObject
    {
        public string? FTS { get; set; }

        public int? Page { get; set; }

        public int? PageSize { get; set; }
    }
}

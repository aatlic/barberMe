using BarberMe.Model.Enum;

namespace BarberMe.Model.SearchObjects
{
    public class SupportRequestSearchObject : BaseSearchObject
    {
        public SupportRequestStatus? Status { get; set; }
    }
}

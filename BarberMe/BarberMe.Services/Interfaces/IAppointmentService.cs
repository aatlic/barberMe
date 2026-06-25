using BarberMe.API.Interfaces;
using BarberMe.Model.Requests.Appointment;
using BarberMe.Model.Responses.Appointment;
using BarberMe.Model.SearchObjects;

namespace BarberMe.Services.Interfaces
{
    public interface IAppointmentService :
                    ICRUDService<
                    AppointmentResponse,
                    AppointmentSearchObject,
                    AppointmentInsertRequest,
                    AppointmentUpdateRequest>
    {
        Task<List<AvailableSlotResponse>> GetAvailableSlots(
                                            int barberId,
                                            int serviceId,
                                            DateOnly date);

        Task CancelAppointment(int id);

        Task ConfirmAppointment(int id);
    }
}

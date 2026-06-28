using BarberMe.Model.Requests.Appointment;
using BarberMe.Model.Responses.Appointment;
using BarberMe.Model.SearchObjects;

namespace BarberMe.Services.Interfaces
{
    public interface IAppointmentService :
                    IService<
                    AppointmentResponse,
                    AppointmentSearchObject>
    {
        Task<List<AvailableSlotResponse>> GetAvailableSlots(
                                            int barberId,
                                            int serviceId,
                                            DateOnly date);
        Task<AppointmentResponse> InsertAsync(AppointmentInsertRequest request);
        Task<AppointmentResponse?> UpdateAsync(int id, AppointmentUpdateRequest request);

        Task CancelAppointment(int id, AppointmentUpdateRequest request);

        Task ConfirmAppointment(int id);
    }
}

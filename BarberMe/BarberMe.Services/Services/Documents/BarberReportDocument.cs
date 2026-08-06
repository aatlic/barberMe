using BarberMe.Model.Responses.Report;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;

namespace BarberMe.Services.Documents
{
    public class BarberReportDocument : IDocument
    {
        private readonly ReportResponse _report;

        public BarberReportDocument(ReportResponse report)
        {
            _report = report;
        }

        public DocumentMetadata GetMetadata()
        {
            return DocumentMetadata.Default;
        }

        public void Compose(IDocumentContainer container)
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4.Landscape());
                page.Margin(30);
                page.DefaultTextStyle(x => x.FontSize(10));

                page.Header().Element(ComposeHeader);
                page.Content().PaddingVertical(15).Element(ComposeContent);
                page.Footer().Element(ComposeFooter);
            });
        }

        private void ComposeHeader(IContainer container)
        {
            container
                .BorderBottom(1)
                .BorderColor(Colors.Grey.Lighten2)
                .PaddingBottom(10)
                .Row(row =>
                {
                    row.RelativeItem().Column(column =>
                    {
                        column.Item()
                            .Text("BARBER ME")
                            .FontSize(20)
                            .Bold();

                        column.Item()
                            .Text("Appointment report")
                            .FontSize(13);
                    });

                    row.ConstantItem(180)
                        .AlignRight()
                        .Column(column =>
                        {
                            column.Item()
                                .AlignRight()
                                .Text($"Generated: {_report.GeneratedAt:dd.MM.yyyy HH:mm}");

                            column.Item()
                                .AlignRight()
                                .Text(
                                    $"Period: {_report.DateFrom:dd.MM.yyyy} - " +
                                    $"{_report.DateTo:dd.MM.yyyy}");
                        });
                });
        }

        private void ComposeContent(IContainer container)
        {
            container.Column(column =>
            {
                column.Spacing(15);

                column.Item().Element(ComposeFilterInformation);
                column.Item().Element(ComposeSummary);

                column.Item()
                    .Text("Services")
                    .FontSize(14)
                    .Bold();

                column.Item().Element(ComposeServicesTable);

                column.Item()
                    .PaddingTop(10)
                    .Text("Appointments")
                    .FontSize(14)
                    .Bold();

                column.Item().Element(ComposeAppointmentsTable);
            });
        }

        private void ComposeFilterInformation(IContainer container)
        {
            container
                .Background(Colors.Grey.Lighten4)
                .Padding(10)
                .Column(column =>
                {
                    column.Item()
                        .Text($"Barber: {_report.BarberName}")
                        .SemiBold();

                    column.Item()
                        .Text(
                            $"Reporting period: " +
                            $"{_report.DateFrom:dd.MM.yyyy} - " +
                            $"{_report.DateTo:dd.MM.yyyy}");
                });
        }

        private void ComposeSummary(IContainer container)
        {
            container.Row(row =>
            {
                row.Spacing(8);

                row.RelativeItem().Element(card =>
                    ComposeSummaryCard(
                        card,
                        "Appointments",
                        _report.TotalAppointments.ToString()));

                row.RelativeItem().Element(card =>
                    ComposeSummaryCard(
                        card,
                        "Completed",
                        _report.CompletedAppointments.ToString()));

                row.RelativeItem().Element(card =>
                    ComposeSummaryCard(
                        card,
                        "Cancelled",
                        _report.CancelledAppointments.ToString()));

                row.RelativeItem().Element(card =>
                    ComposeSummaryCard(
                        card,
                        "Clients",
                        _report.UniqueClients.ToString()));

                row.RelativeItem().Element(card =>
                    ComposeSummaryCard(
                        card,
                        "Revenue",
                        $"{_report.TotalRevenue:N2} KM"));
            });
        }

        private static void ComposeSummaryCard(
            IContainer container,
            string title,
            string value)
        {
            container
                .Border(1)
                .BorderColor(Colors.Grey.Lighten2)
                .Padding(8)
                .Column(column =>
                {
                    column.Item()
                        .AlignCenter()
                        .Text(title)
                        .FontSize(8);

                    column.Item()
                        .PaddingTop(4)
                        .AlignCenter()
                        .Text(value)
                        .FontSize(12)
                        .Bold();
                });
        }

        private void ComposeServicesTable(IContainer container)
        {
            container.Table(table =>
            {
                table.ColumnsDefinition(columns =>
                {
                    columns.ConstantColumn(35);
                    columns.RelativeColumn(3);
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                });

                table.Header(header =>
                {
                    header.Cell().Element(HeaderCell).Text("#");
                    header.Cell().Element(HeaderCell).Text("Service");
                    header.Cell().Element(HeaderCell).Text("Count");
                    header.Cell().Element(HeaderCell).Text("Price");
                    header.Cell().Element(HeaderCell).Text("Revenue");
                });

                if (_report.Services.Count == 0)
                {
                    table.Cell()
                        .ColumnSpan(5)
                        .Element(BodyCell)
                        .AlignCenter()
                        .Text("No services found for the selected period.");

                    return;
                }

                var index = 1;

                foreach (var service in _report.Services)
                {
                    table.Cell()
                        .Element(BodyCell)
                        .Text(index.ToString());

                    table.Cell()
                        .Element(BodyCell)
                        .Text(service.ServiceName);

                    table.Cell()
                        .Element(BodyCell)
                        .Text(service.AppointmentCount.ToString());

                    table.Cell()
                        .Element(BodyCell)
                        .Text($"{service.UnitPrice:N2} KM");

                    table.Cell()
                        .Element(BodyCell)
                        .Text($"{service.TotalRevenue:N2} KM");

                    index++;
                }
            });
        }

        private void ComposeAppointmentsTable(IContainer container)
        {
            container.Table(table =>
            {
                table.ColumnsDefinition(columns =>
                {
                    columns.ConstantColumn(25);
                    columns.RelativeColumn(1.8f);
                    columns.RelativeColumn(1.8f);
                    columns.RelativeColumn(1.8f);
                    columns.RelativeColumn(1.5f);
                    columns.RelativeColumn(1.1f);
                    columns.RelativeColumn(0.7f);
                    columns.RelativeColumn();
                    columns.RelativeColumn(0.8f);
                    columns.RelativeColumn(0.8f);
                    columns.RelativeColumn();
                });

                table.Header(header =>
                {
                    header.Cell().Element(HeaderCell).Text("#");
                    header.Cell().Element(HeaderCell).Text("Client");
                    header.Cell().Element(HeaderCell).Text("Barber");
                    header.Cell().Element(HeaderCell).Text("Service");
                    header.Cell().Element(HeaderCell).Text("Date");
                    header.Cell().Element(HeaderCell).Text("Status");
                    header.Cell().Element(HeaderCell).Text("Paid");
                    header.Cell().Element(HeaderCell).Text("Base");
                    header.Cell().Element(HeaderCell).Text("Discount");
                    header.Cell().Element(HeaderCell).Text("Penalty");
                    header.Cell().Element(HeaderCell).Text("Final");
                });

                if (_report.Appointments.Count == 0)
                {
                    table.Cell()
                        .ColumnSpan(11)
                        .Element(BodyCell)
                        .AlignCenter()
                        .Text("No appointments found for the selected period.");

                    return;
                }

                var index = 1;

                foreach (var appointment in _report.Appointments)
                {
                    table.Cell()
                        .Element(BodyCell)
                        .Text(index.ToString());

                    table.Cell()
                        .Element(BodyCell)
                        .Text(appointment.ClientName);

                    table.Cell()
                        .Element(BodyCell)
                        .Text(appointment.BarberName);

                    table.Cell()
                        .Element(BodyCell)
                        .Text(appointment.ServiceName);

                    table.Cell()
                        .Element(BodyCell)
                        .Text(
                            appointment.StartDateTime.ToString(
                                "dd.MM.yyyy HH:mm"));

                    table.Cell()
                        .Element(BodyCell)
                        .Text(appointment.Status);

                    table.Cell()
                        .Element(BodyCell)
                        .AlignCenter()
                        .Text(appointment.IsPaid ? "Yes" : "No");

                    table.Cell()
                        .Element(BodyCell)
                        .Text($"{appointment.BasePrice:N2} KM");

                    table.Cell()
                        .Element(BodyCell)
                        .AlignCenter()
                        .Text($"{appointment.AppliedDiscountPercent:N2}%");

                    table.Cell()
                        .Element(BodyCell)
                        .AlignCenter()
                        .Text($"{appointment.AppliedPenaltyPercent:N2}%");

                    table.Cell()
                        .Element(BodyCell)
                        .Text($"{appointment.FinalPrice:N2} KM");

                    index++;
                }
            });
        }

        private static IContainer HeaderCell(IContainer container)
        {
            return container
                .Background(Colors.Grey.Lighten3)
                .BorderBottom(1)
                .BorderColor(Colors.Grey.Medium)
                .PaddingVertical(5)
                .PaddingHorizontal(3)
                .DefaultTextStyle(x => x.SemiBold().FontSize(8));
        }

        private static IContainer BodyCell(IContainer container)
        {
            return container
                .BorderBottom(1)
                .BorderColor(Colors.Grey.Lighten3)
                .PaddingVertical(5)
                .PaddingHorizontal(3)
                .DefaultTextStyle(x => x.FontSize(8));
        }

        private static void ComposeFooter(IContainer container)
        {
            container
                .BorderTop(1)
                .BorderColor(Colors.Grey.Lighten2)
                .PaddingTop(5)
                .Row(row =>
                {
                    row.RelativeItem()
                        .Text("Barber Me");

                    row.RelativeItem()
                        .AlignRight()
                        .Text(text =>
                        {
                            text.Span("Page ");
                            text.CurrentPageNumber();
                            text.Span(" of ");
                            text.TotalPages();
                        });
                });
        }
    }
}
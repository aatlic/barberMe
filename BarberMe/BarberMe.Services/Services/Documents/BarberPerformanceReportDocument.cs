using BarberMe.Model.Responses.Report;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;

namespace BarberMe.Services.Documents
{
    public class BarberPerformanceReportDocument : IDocument
    {
        private readonly BarberPerformanceReportResponse _report;

        public BarberPerformanceReportDocument(
            BarberPerformanceReportResponse report)
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
                page.Size(PageSizes.A4);
                page.Margin(30);
                page.DefaultTextStyle(x => x.FontSize(10));

                page.Header().Element(ComposeHeader);

                page.Content()
                    .PaddingVertical(15)
                    .Element(ComposeContent);

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
                            .Text("Barber performance report")
                            .FontSize(13);
                    });

                    row.ConstantItem(180)
                        .AlignRight()
                        .Column(column =>
                        {
                            column.Item()
                                .AlignRight()
                                .Text(
                                    $"Generated: " +
                                    $"{_report.GeneratedAt:dd.MM.yyyy HH:mm}");

                            column.Item()
                                .AlignRight()
                                .Text(
                                    $"Period: " +
                                    $"{_report.DateFrom:dd.MM.yyyy} - " +
                                    $"{_report.DateTo:dd.MM.yyyy}");
                        });
                });
        }

        private void ComposeContent(IContainer container)
        {
            container.Column(column =>
            {
                column.Spacing(15);

                column.Item().Element(ComposeSummary);

                column.Item()
                    .Text("Barber performance")
                    .FontSize(14)
                    .Bold();

                column.Item().Element(ComposeBarbersTable);
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
                        "Barbers",
                        _report.Barbers.Count.ToString()));

                row.RelativeItem().Element(card =>
                    ComposeSummaryCard(
                        card,
                        "Completed",
                        _report.TotalCompletedAppointments.ToString()));

                row.RelativeItem().Element(card =>
                    ComposeSummaryCard(
                        card,
                        "Clients",
                        _report.TotalUniqueClients.ToString()));

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

        private void ComposeBarbersTable(IContainer container)
        {
            container.Table(table =>
            {
                table.ColumnsDefinition(columns =>
                {
                    columns.ConstantColumn(30);
                    columns.RelativeColumn(2.2f);
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                    columns.RelativeColumn(1.2f);
                    columns.RelativeColumn();
                    columns.RelativeColumn(2);
                });

                table.Header(header =>
                {
                    header.Cell().Element(HeaderCell).Text("#");
                    header.Cell().Element(HeaderCell).Text("Barber");
                    header.Cell().Element(HeaderCell).Text("Appointments");
                    header.Cell().Element(HeaderCell).Text("Clients");
                    header.Cell().Element(HeaderCell).Text("Revenue");
                    header.Cell().Element(HeaderCell).Text("Rating");
                    header.Cell().Element(HeaderCell).Text("Top service");
                });

                if (_report.Barbers.Count == 0)
                {
                    table.Cell()
                        .ColumnSpan(7)
                        .Element(BodyCell)
                        .AlignCenter()
                        .Text(
                            "No completed appointments were found " +
                            "for the selected period.");

                    return;
                }

                var index = 1;

                foreach (var barber in _report.Barbers)
                {
                    table.Cell()
                        .Element(BodyCell)
                        .Text(index.ToString());

                    table.Cell()
                        .Element(BodyCell)
                        .Text(barber.BarberName);

                    table.Cell()
                        .Element(BodyCell)
                        .Text(
                            barber.CompletedAppointments.ToString());

                    table.Cell()
                        .Element(BodyCell)
                        .Text(barber.UniqueClients.ToString());

                    table.Cell()
                        .Element(BodyCell)
                        .Text($"{barber.TotalRevenue:N2} KM");

                    table.Cell()
                        .Element(BodyCell)
                        .Text(
                            barber.AverageRating > 0
                                ? barber.AverageRating.ToString("N2")
                                : "-");

                    table.Cell()
                        .Element(BodyCell)
                        .Text(barber.MostPopularService);

                    index++;
                }
            });
        }

        private static IContainer HeaderCell(IContainer container)
        {
            return container
                .Background(Colors.Grey.Lighten3)
                .BorderBottom(1)
                .BorderColor(Colors.Grey.Lighten1)
                .PaddingVertical(6)
                .PaddingHorizontal(4)
                .DefaultTextStyle(x => x.SemiBold().FontSize(8));
        }

        private static IContainer BodyCell(IContainer container)
        {
            return container
                .BorderBottom(1)
                .BorderColor(Colors.Grey.Lighten3)
                .PaddingVertical(6)
                .PaddingHorizontal(4)
                .DefaultTextStyle(x => x.FontSize(8));
        }

        private static void ComposeFooter(IContainer container)
        {
            container
                .BorderTop(1)
                .BorderColor(Colors.Grey.Lighten2)
                .PaddingTop(8)
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
using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eBiblioteka.Servisi.Migrations
{
    /// <inheritdoc />
    public partial class addDatumURecenzije : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "DatumRecenzije",
                table: "Recenzija",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DatumRecenzije",
                table: "Recenzija");
        }
    }
}

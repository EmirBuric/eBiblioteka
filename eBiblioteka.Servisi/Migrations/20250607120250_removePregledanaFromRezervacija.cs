using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eBiblioteka.Servisi.Migrations
{
    /// <inheritdoc />
    public partial class removePregledanaFromRezervacija : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Pregledana",
                table: "Rezervacija");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "Pregledana",
                table: "Rezervacija",
                type: "bit",
                nullable: true,
                defaultValue: false);
        }
    }
}

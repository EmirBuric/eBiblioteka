using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eBiblioteka.Servisi.Migrations
{
    /// <inheritdoc />
    public partial class addSlikaTOAutor : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<byte[]>(
                name: "Slika",
                table: "Autor",
                type: "varbinary(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Slika",
                table: "Autor");
        }
    }
}

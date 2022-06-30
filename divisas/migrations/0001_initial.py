# Generated by Django 2.2.7 on 2019-11-28 08:39

from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Divisa',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('codigo', models.CharField(max_length=3, verbose_name='código')),
                ('descripcion', models.TextField(verbose_name='descripción')),
            ],
            options={
                'verbose_name': 'divisa',
                'verbose_name_plural': 'divisas',
            },
        ),
    ]
